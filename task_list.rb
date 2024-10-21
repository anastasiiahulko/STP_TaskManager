# frozen_string_literal: true

require_relative 'task'

# Клас TaskList зберігає масив завдань і максимальну кількість доступних ресурсів.
# Він реалізує метод гілок та меж для пошуку найкращого списку завдань, готових до виконання.
class TaskList
	def initialize(total_resources, task_list = [])
		@total_resources = total_resources
		# Сортуємо завдання за початковим часом (t_start)
		@tasks = task_list.sort_by(&:t_start)
	end

	def add(task)
		@tasks.push(task)
	end

	def generate_task_list(t_start = time_start, t_end = time_end, result = [])
		return [sum_tasks_priority(result), result] if t_start > t_end

		# Переходимо до пошуку найкращих комбінацій завдань
		best_combination_result(t_start, t_end, result)
	end

	private

	def best_combination_result(t_start, t_end, result) # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
		sum_priority = sum_tasks_priority(result)
		res = [sum_priority, result]

		# Отримуємо завдання, які починаються з поточного моменту часу і не були вибрані раніше
		available_tasks = @tasks.select { |task| task.t_start >= t_start && !result.include?(task) }

		# Генеруємо всі валідні комбінації цих завдань
		available_combinations = valid_combinations(available_tasks, result)
		available_combinations.each do |combo|
			res = process_combination(t_start, t_end, res, result, combo)
		end

		# Розглядаємо випадок, коли не додаємо нові завдання в цей момент
		future_max_priority = max_future_priority(t_start + 1, t_end, result)
		if (sum_priority + future_max_priority) > res[0]
			tmp_result = generate_task_list(t_start + 1, t_end, result)
			res = select_better_result(res, tmp_result)
		end

		res
	end

	# Обробляємо окрему комбінацію завдань
	def process_combination(t_start, t_end, res, result, combo)
		new_result = result + combo
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
		# Генеруємо всі можливі комбінації доступних завдань
		(1..available_tasks.size).flat_map do |i|
			available_tasks.combination(i).select do |combo|
				tasks_to_check = current_result + combo
				resource_usage_valid?(tasks_to_check)
			end
		end
	end

	# Перевіряємо, чи завдання не перевищують обмежень ресурсів в будь-який момент часу
	def resource_usage_valid?(tasks)
		# Отримуємо унікальні відсортовані моменти часу, коли будь-яке завдання починається або завершується
		time_points = tasks.flat_map { |task| [task.t_start, task.t_end] }.uniq.sort

		# Проходимо по кожній парі послідовних моментів часу
		time_points.each_cons(2) do |start_time, _|
			# Отримуємо всі завдання, активні протягом цього інтервалу часу
			active_tasks = tasks.select { |task| task.t_start <= start_time && task.t_end > start_time }
			total_resources_used = sum_tasks_resources(active_tasks)
			return false if total_resources_used > @total_resources
		end
		true
	end

	def select_better_result(res, new_res)
		# Обираємо результат з більшою сумою пріоритетів
		if new_res[0] > res[0]
			new_res
		elsif new_res[0] == res[0]
			# Якщо суми пріоритетів рівні, обираємо той, що має більше завдань
			new_res[1].size > res[1].size ? new_res : res
		else
			res
		end
	end

	def max_future_priority(t_start, _t_end, current_selected)
		future_tasks = @tasks - current_selected
		future_tasks = future_tasks.select { |task| task.t_end > t_start }

		# Максимальний можливий пріоритет у майбутньому - це сума пріоритетів усіх майбутніх завдань
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
