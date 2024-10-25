# frozen_string_literal: true

require 'minitest/autorun'
require_relative '../task_list'
require_relative '../task'

# testing class TaskList
class TestTaskList < Minitest::Test # rubocop:disable Metrics/ClassLength
	def setup
		@task1 = Task.new(1, 5, 10, 2)
		@task2 = Task.new(2, 6, 20, 1)
		@task3 = Task.new(3, 7, 5, 3)
		@task4 = Task.new(4, 8, 15, 1)
		@task5 = Task.new(5, 9, 20, 5)
		@task_list = TaskList.new(4, [@task1, @task2, @task3])
	end

	def test_initialize
		assert_equal 4, @task_list.instance_variable_get(:@total_resources)
		assert_includes @task_list.instance_variable_get(:@tasks), @task1
		assert_includes @task_list.instance_variable_get(:@tasks), @task2
		assert_includes @task_list.instance_variable_get(:@tasks), @task3
	end

	def test_add
		@task_list.add(@task4)
		assert_equal @task_list.count, 4
		assert_includes @task_list.instance_variable_get(:@tasks), @task4
	end

	def test_time_start
		assert_equal 1, @task_list.send(:time_start)
	end

	def test_time_end
		assert_equal 7, @task_list.send(:time_end)
	end

	def test_sum_tasks_priority
		result = @task_list.send(:sum_tasks_priority, [@task1, @task2])
		assert_equal 30, result
	end

	def test_sum_tasks_resources
		result = @task_list.send(:sum_tasks_resources, [@task1, @task2])
		assert_equal 3, result
	end

	def test_max_future_priority
		result = @task_list.send(:max_future_priority, 1, 8, [@task1])
		assert_equal 25, result
	end

	def test_select_better_result
		result = @task_list.send(:select_better_result, [1, [@task2, @task1]], [2, [@task4, @task3]])
		assert_equal [2, [@task3, @task4]], result
		result = @task_list.send(:select_better_result, [2, [@task2, @task1]], [1, [@task4, @task3]])
		assert_equal [2, [@task2, @task1]], result
		result = @task_list.send(:select_better_result, [1, [@task2, @task1]], [1, [@task4, @task3]])
		assert_equal [1, [@task2, @task1]], result
		result = @task_list.send(:select_better_result, [1, [@task1]], [1, [@task4, @task3]])
		assert_equal [1, [@task3, @task4]], result
	end

	def test_resource_usage_valid?
		result = @task_list.send(:resource_usage_valid?, [@task4, @task1, @task2])
		assert_equal true, result
		result = @task_list.send(:resource_usage_valid?, [@task4, @task1, @task2, @task3])
		assert_equal false, result
		result = @task_list.send(:resource_usage_valid?, [@task1])
		assert_equal true, result
		result = @task_list.send(:resource_usage_valid?, [@task5])
		assert_equal false, result
	end

	def test_valid_combinations
		result = @task_list.send(:valid_combinations, [@task4, @task1, @task2], [@task3])
		assert_equal [[@task2], [@task4]], result
		result = @task_list.send(:valid_combinations, [@task1, @task3, @task4], [@task2])
		assert_equal [[@task1, @task4], [@task4], [@task1], [@task3]], result
	end

	def test_process_combination
		initial_result = [@task1]
		combo = [@task2]
		t_start = 1
		t_end = 7
		expected_result = [30, [@task1, @task2]]
		actual_result = @task_list.send(:process_combination, t_start, t_end, [10, [@task1]], initial_result, combo)
		assert_equal expected_result[0], actual_result[0]
		assert_equal expected_result[1], actual_result[1]
	end

	def test_consider_no_task_option
		t_start = 1
		t_end = 7
		result = [@task1]
		sum_priority = 10
		expected_result = [30, [@task1, @task2]]
		actual_result = @task_list.send(:consider_no_task_option, t_start, t_end, result, sum_priority, [10, [@task1]])
		assert_equal expected_result[0], actual_result[0]
		assert_equal expected_result[1], actual_result[1]
	end

	def test_find_valid_combinations
		t_start = 2
		result = []
		expected_combinations = [[@task2, @task3], [@task2], [@task3]]
		actual_combinations = @task_list.send(:find_valid_combinations, t_start, result)
		assert_equal expected_combinations, actual_combinations
	end

	def test_best_combination_result
		t_start = 1
		t_end = 7
		result = [@task1]
		expected_result = [30, [@task1, @task2]]
		actual_result = @task_list.send(:best_combination_result, t_start, t_end, result)
		assert_equal expected_result[0], actual_result[0]
		assert_equal expected_result[1], actual_result[1]
	end

	def test_generate_task_list
		result = @task_list.generate_task_list
		assert_equal 30, result[0]
		assert_equal [@task1, @task2], result[1]
	end
end
