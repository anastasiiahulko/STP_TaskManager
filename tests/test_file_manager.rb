# frozen_string_literal: true

require 'minitest/autorun'
require 'csv'
require_relative '../file_manager'
require_relative '../task_list'
require_relative '../task'
require_relative '../constants'

# testing class FileManager
class TestFileManager < Minitest::Test
	def setup
		@file_path = 'test_tasks.csv'
		@output_file_path = 'test_output.csv'
		@task_list = nil
		@task = Task.new(0, 1, 2, 3)

		File.write(@file_path, "total_resources: 7\n")
		CSV.open(@file_path, 'a', col_sep: ', ') do |csv|
			csv << %w[start end priority resorces]
			csv << [1, 2, 10, 5]
			csv << [2, 3, 20, 10]
		end
	end

	def test_open_and_validate_file
		file = FileManager.open_and_validate_file(@file_path)
		assert_instance_of File, file
		file.close
	end

	def test_open_and_validate_file_not_found
		result = FileManager.open_and_validate_file('test_non_existent_file.csv')
		assert_nil result
	end

	def test_update_tasks_from_file
		@task_list = FileManager.update_tasks_from_file(@file_path)
		assert_instance_of TaskList, @task_list
		assert_equal 2, @task_list.count
	end

	def test_write_tasks_to_file
		max_sum_priority = 4
		tasks = [@task, @task]
		rows = tasks.map { |task| "#{task.t_start}, #{task.t_end}, #{task.priority}, #{task.resources}" }
		result = (['start, end, priority, resorces'] + rows).join("\n")

		FileManager.write_tasks_to_file(@output_file_path, max_sum_priority, tasks)

		assert File.exist?(@output_file_path)
		content = File.read(@output_file_path)
		assert_equal("max_sum_priority: #{max_sum_priority}\n#{result}\n", content)
	end

	def test_export_csv
		data_hashes = [{ start: 1, end: 2, priority: 10, resorces: 5 }, { start: 2, end: 3, priority: 20, resorces: 10 }]
		FileManager.export_csv(data_hashes, @output_file_path)

		assert File.exist?(@output_file_path)
		content = File.read(@output_file_path)
		assert_match(/start, end, priority, resorces/, content)
	end

	def teardown
		FileUtils.rm_f(@file_path)
		FileUtils.rm_f(@output_file_path)
	end
end
