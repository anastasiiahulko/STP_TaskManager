# frozen_string_literal: true

require 'minitest/autorun'
require_relative 'task'

# testing class Task
class TestTask < Minitest::Test
	def setup
		@task = Task.new(1, 5, 10, 2)
	end

	# Перевірка чи об'єкт Task правильно ініціалізований
	def test_initialize
		assert_equal 1, @task.t_start
		assert_equal 5, @task.t_end
		assert_equal 10, @task.priority
		assert_equal 2, @task.resources
	end

	# Перевірка чи метод t_start повертає початковий час завдання 1
	def test_t_start
		assert_equal 1, @task.t_start
	end

	# Перевірка чи метод t_end повертає кінцевий час завдання 5
	def test_t_end
		assert_equal 5, @task.t_end
	end

	# Перевірка чи метод priority повертає пріоритет завдання 10
	def test_priority
		assert_equal 10, @task.priority
	end

	# Перевірка чи метод resources повертає кількість ресурсів, необхідних для завдання 2
	def test_resources
		assert_equal 2, @task.resources
	end
end
