# frozen_string_literal: true

require 'minitest/autorun'
require 'stringio'
require 'csv'
require_relative 'constants'
require_relative 'task_list'

# testing class Program
class MainProgramTest < Minitest::Test
	def setup # rubocop:disable Metrics/MethodLength
		# Заміняємо стандартний вивід на StringIO
		@output = StringIO.new
		@original_stdout = $stdout
		$stdout = @output

		# Створюємо підроблені дані для тестування
		@task1 = Task.new(1, 5, 10, 2)
		@task2 = Task.new(2, 6, 20, 1)
		@task3 = Task.new(3, 7, 5, 3)
		@task_list = TaskList.new(4, [@task1, @task2, @task3])

		# Створюємо підроблений файл з входними даними
		@file_path = 'test_input_file.csv'
		CSV.open(@file_path, 'w') do |csv|
			csv << %w[t_start t_end priority resources]
			csv << [1, 5, 10, 2]
			csv << [2, 6, 20, 1]
			csv << [3, 7, 5, 3]
		end
	end

	def teardown
		# Відновлюємо стандартний вивід і видаляємо підроблений файл
		$stdout = @original_stdout
		File.delete(@file_path)
	end

	# Перевірка чи вивід включає значення константи AUTHOR
	def test_author_output
		assert_output(/#{Constants::AUTHOR}/) { puts Constants::AUTHOR }
	end

	# Перевірка чи метод generate_task_list повертає максимальну суму пріоритетів 30 та список завдань [task1, task2]
	def test_tasks_list_generation
		tasks_list = @task_list
		sum_priority, result_task_list = tasks_list.generate_task_list
		assert_equal 150, sum_priority # highest sum priority
		assert_equal [@task1, @task2], result_task_list
	end

	# Перевірка чи результати генеруються і зберігаються у вихідний файл, а файл дійсно існує після запису
	def test_output_result # rubocop:disable Metrics/MethodLength
		tasks_list = @task_list
		sum_priority, result_task_list = tasks_list.generate_task_list
		output_file = 'test_output_file.txt'
		File.open(output_file, 'w') do |file|
			file.puts "max_sum_priority: #{sum_priority}"
			file.puts 't_start, t_end, priority, resources'
			result_task_list.each do |task|
				file.puts "#{task.t_start}, #{task.t_end}, #{task.priority}, #{task.resources}"
			end
		end
		assert File.exist?(output_file)
		File.delete(output_file)
	end
end
