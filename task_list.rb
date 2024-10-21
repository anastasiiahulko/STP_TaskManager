# frozen_string_literal: true

require_relative 'task'

# Клас TaskList зберігає масив завдань і максимальну кількість доступних ресурсів.
# Він реалізує метод гілок та меж для пошуку найкращого списку завдань, готових до виконання.
class TaskList
	def initialize(total_resources, task_list = [])
		@total_resources = total_resources
		# Сортуємо завдання за пріоритетом у порядку спадання
		@tasks = task_list.sort_by { |t| -t.priority }
	end

	def add(task)
		@tasks.push(task)
		# Після додавання нового завдання, знову сортуємо список за пріоритетом
		@tasks.sort_by! { |t| -t.priority }
	end

	def generate_task_list(t_start = time_start, t_end = time_end, result = [])
		if t_start > t_end
			# Перед поверненням результату сортуємо його за часом початку
			return [sum_tasks_priority(result), result.sort_by(&:t_start)]
		end

		# Переходимо до пошуку найкращих комбінацій завдань
		best_combination_result(t_start, t_end, result)
	end

	private

	def best_combination_result(t_start, t_end, result)
		sum_priority = sum_tasks_priority(result)
		res = [sum_priority, result.sort_by(&:t_start)] # Сортуємо результат

		# Отримуємо всі валідні комбінації завдань
		available_combinations = find_valid_combinations(t_start, result)

		# Обробляємо кожну комбінацію
		available_combinations.each do |combo|
			res = process_combination(t_start, t_end, res, result, combo)
		end

		# Перевіряємо можливість не додавати нові завдання
		consider_no_task_option(t_start, t_end, result, sum_priority, res)
	end

	# Отримуємо валідні комбінації доступних завдань
	def find_valid_combinations(t_start, result)
		available_tasks = @tasks.select { |task| task.t_start >= t_start && !result.include?(task) }
		# Сортуємо доступні завдання за пріоритетом у порядку спадання
		available_tasks.sort_by! { |task| -task.priority }
		# Генеруємо всі валідні комбінації
		valid_combinations(available_tasks, result)
	end

	# Розглядаємо варіант, коли не додаємо нові завдання в цей момент
	def consider_no_task_option(t_start, t_end, result, sum_priority, res)
		future_max_priority = max_future_priority(t_start + 1, t_end, result)
		if (sum_priority + future_max_priority) > res[0]
			tmp_result = generate_task_list(t_start + 1, t_end, result)
			res = select_better_result(res, tmp_result)
		end
		res
	end

	# Обробляємо окрему комбінацію завдань
	def process_combination(t_start, t_end, res, result, combo)
		new_result = (result + combo).sort_by(&:t_start) # Сортуємо новий результат
		current_priority = sum_tasks_priority(new_result)

		# Перевірка, чи обрана комбінація не перевищує ресурси
		return res unless resource_usage_valid?(new_result)

		# Відсікання гілок, які не можуть дати кращий результат
		future_max_priority = max_future_priority(t_start + 1, t_end, new_result)
		return res if (current_priority + future_max_priority) <= res[0]

		# Рекурсивно перевіряємо наступний момент часу з новим результатом
		tmp_result = generate_task_list(t_start + 1, t_end, new_result)

		# Обираємо кращий результат між поточним та рекурсивним
		select_better_result(res, tmp_result)
	end

	# Генеруємо валідні комбінації завдань, які, додані до результату,
	# не перевищують обмежень ресурсів в будь-який момент часу
	def valid_combinations(available_tasks, current_result)
		combinations = []
		(1..available_tasks.size).flat_map do |i|
			available_tasks.combination(i).each do |combo|
				tasks_to_check = current_result + combo
				combinations << combo if resource_usage_valid?(tasks_to_check)
			end
		end
		# Сортуємо комбінації за сумарним пріоритетом у порядку спадання
		combinations.sort_by { |combo| -sum_tasks_priority(combo) }
	end

	# Перевіряємо, чи завдання не перевищують обмежень ресурсів в будь-який момент часу
	def resource_usage_valid?(tasks)
		time_points = tasks.flat_map { |task| [task.t_start, task.t_end] }.uniq.sort

		time_points.each do |time_point|
			active_tasks = tasks.select { |task| task.t_start <= time_point && task.t_end > time_point }
			total_resources_used = sum_tasks_resources(active_tasks)
			return false if total_resources_used > @total_resources
		end
		true
	end

	def select_better_result(res, new_res) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
		if new_res[0] > res[0]
			[new_res[0], new_res[1].sort_by(&:t_start)]
		elsif new_res[0] == res[0]
			if new_res[1].size > res[1].size
				[new_res[0], new_res[1].sort_by(&:t_start)]
			else
				res
			end
		else
			res
		end
	end

	def max_future_priority(t_start, _t_end, current_selected)
		future_tasks = @tasks - current_selected
		future_tasks = future_tasks.select { |task| task.t_end > t_start }

		future_tasks.map(&:priority).sum
	end

	def time_start
		@tasks.map(&:t_start).min
	end

	def time_end
		@tasks.map(&:t_end).max
	end

	def sum_tasks_priority(tasks)
		tasks.map(&:priority).sum
	end

	def sum_tasks_resources(tasks)
		tasks.map(&:resources).sum
	end
end
