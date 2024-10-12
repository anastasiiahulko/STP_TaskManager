# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'task_list'
require_relative 'task'

# testing class TaskList
class TestTaskList < Minitest::Test
	def setup
		@task1 = Task.new(1, 5, 10, 2)
		@task2 = Task.new(2, 6, 20, 1)
		@task3 = Task.new(3, 7, 5, 3)
		@task_list = TaskList.new(4, [@task1, @task2, @task3])
	end

	def test_initialize
		assert_equal 4, @task_list.instance_variable_get(:@_total_resources)
		assert_equal [@task1, @task2, @task3], @task_list.instance_variable_get(:@_tasks)
	end

	# Перевірка чи метод add додає нове завдання до списку завдань
	def test_add
		task4 = Task.new(4, 8, 15, 1)
		@task_list.add(task4)
		assert_includes @task_list.instance_variable_get(:@_tasks), task4
	end

	# Перевірка методу generate_task_list, чи повертає правильну комбінацію завдань з найвищою сумою пріоритетів
	# Failure
	def test_generate_task_list
		result = @task_list.generate_task_list
		assert_equal 30, result[0] # найбільша сума пріоритетів
		assert_equal [@task1, @task2], result[1]
	end

	# Перевірка методу time_start, чи правильно визначає початковий час
	def test_time_start
		assert_equal 1, @task_list.send(:time_start)
	end

	# Перевірка методу time_end, чи правильно визначає кінцевий час
	def test_time_end
		assert_equal 7, @task_list.send(:time_end)
	end

	# Перевірка чи метод tasks_at_time правильно визначає завдання, які відбуваються у визначений час
	def test_tasks_at_time
		result = @task_list.send(:tasks_at_time, 3)
		assert_equal [@task1, @task2, @task3], result
	end

	# Перевірка чи метод sum_tasks_priority правильно визначає суму пріоритетів завдань
	def test_sum_tasks_priority
		result = @task_list.send(:sum_tasks_priority, [@task1, @task2])
		assert_equal 30, result
	end

	# Перевіка методу sum_tasks_resources, чи правильно визначає суму ресурсів завдань.
	def test_sum_tasks_resources
		result = @task_list.send(:sum_tasks_resources, [@task1, @task2])
		assert_equal 3, result
	end

	# Перевірка методу sum_tasks_field, чи правильно визначає суму заданого поля завдань
	def test_sum_tasks_field
		result = @task_list.send(:sum_tasks_field, :priority, [@task1, @task2])
		assert_equal 30, result
	end

	# Перевірка чи метод valid_combinations_tasks правильно визначає всі допустимі комбінації завдань для заданого часу
	# Failure
	def test_valid_combinations_tasks
		result = @task_list.send(:valid_combinations_tasks, 1)
		assert_equal [[@task1]], result
	end

	# Перевірка чи метод choose_best_result правильно обирає найкращий результат з двох заданих
	def test_choose_best_result
		res1 = [30, [@task1, @task2]]
		res2 = [35, [@task3]]
		result = @task_list.send(:choose_best_result, res1, res2)
		assert_equal res2, result
	end
end
