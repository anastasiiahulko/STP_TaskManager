# frozen_string_literal: true

require_relative 'task'

# Class TaskList stores an array of tasks and the maximum number of available resources from which
# it can generate the best list of tasks ready for execution generate_task_list
class TaskList
	def initialize(total_resources, task_list = [])
		@_total_resources = total_resources
		@_tasks = task_list
	end

	def add(task)
		@_tasks.push(task)
	end

	# rubocop:disable Metrics/ParameterLists

	# The method recursively searches for the best combination of tasks so that the sum of priorities is the highest
	# (if in some variants it is equally high, then the first one found with the largest number of tasks is selected),
	# returns an array in the format [maximum number of priorities, array of selected tasks].
	def generate_task_list(t_start = time_start, t_end = time_end, result = [], sum_priority = 0)
		return [sum_priority, result] if t_start > t_end

		performed_tasks = tasks_at_time(t_start, result)
		free_resources = @_total_resources - sum_tasks_resources(performed_tasks)
		sum_priority += sum_tasks_priority(performed_tasks)

		best_valid_combinations_result_tasks(t_start, t_end, free_resources, result, sum_priority)
		result.reject! { |arr| arr.empty? or arr.include?(nil) }
	end
	# rubocop:enable Metrics/ParameterLists

	private

	def best_valid_combinations_result_tasks(t_start, t_end, free_resources, result, sum_priority)
		res = [sum_priority, result]
		valid_combinations_tasks(t_start, @_tasks - result, free_resources).each do |combo|
			tmp = generate_task_list(t_start + 1, t_end, result + combo, sum_priority + sum_tasks_priority(combo))
			res = choose_best_result(res, tmp)
		end

		res
	end

	def valid_combinations_tasks(time, tasks = @_tasks, total_resources = @_total_resources)
		tasks.select! { |task| task.t_start == time && task.resources <= total_resources }
		valid_combos = []

		(0..tasks.size).each do |i|
			tasks.combination(i).each do |combo|
				valid_combos.push(combo) if combo.map(&:resources).sum <= total_resources
			end
		end

		valid_combos
	end

	def choose_best_result(res, tmp)
		if tmp[0] > res[0]
			res = tmp
		elsif tmp[0] == res[0]
			res = tmp if tmp[1].size > res[1].size
		end

		res
	end

	def time_start
		@_tasks.min_by(&:t_start).t_start
	end

	def time_end
		@_tasks.max_by(&:t_end).t_end
	end

	def tasks_at_time(time, tasks = @_tasks)
		tasks.select { |task| task.t_start <= time && task.t_end >= time }
	end

	def sum_tasks_priority(tasks = @_tasks)
		sum_tasks_field(:priority, tasks)
	end

	def sum_tasks_resources(tasks = @_tasks)
		sum_tasks_field(:resources, tasks)
	end

	def sum_tasks_field(field, tasks = @_tasks)
		return 0 if tasks.nil?

		tasks.map(&field).sum
	end
end
