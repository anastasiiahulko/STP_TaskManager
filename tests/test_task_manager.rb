# frozen_string_literal: true

require 'minitest/autorun'
require 'csv'
require_relative '../file_manager'
require_relative '../constants'

# Конкретний клас для тестування абстрактного класу FileManager
class TestFileManager < FileManager
	def initialize(file_path = Constants::DEFAULT_FILE_INPUT_PATH, output_file_path = Constants::DEFAULT_FILE_OUTPUT_PATH) # rubocop:disable Lint/MissingSuper
		@file_path = file_path
		@output_file_path = output_file_path
		@total_resources = 0
		@data_rows = []
	end

	# Переоприділяємо абстрактний метод, щоб він не викликав помилку
	def update_tasks_from_file # rubocop:disable Lint/UselessMethodDefinition
		super
	end

	def write_tasks_to_file(max_sum_priority, managed_task_list) # rubocop:disable Lint/UselessMethodDefinition
		super
	end
end

# Клас для тестування FileManager з використанням Minitest
class FileManagerTest < Minitest::Test
	def test_initialize_raises_error
		assert_raises(NotImplementedError) { FileManager.new }
	end

	# Перевірка, що не можна створити екземпляр абстрактного класу FileManager
	def test_abstract_class_cannot_be_instantiated
		assert_raises(NotImplementedError) { FileManager.new }
	end

	# Перевірка, що підклас можна створити
	def test_concrete_class_can_be_instantiated
		manager = TestFileManager.new
		assert_instance_of TestFileManager, manager
	end

	# Перевірка, що data_rows є масивом
	def test_data_rows_is_array
		manager = TestFileManager.new
		assert_kind_of Array, manager.instance_variable_get(:@data_rows)
	end

	# Перевірка поведінки, якщо файл не існує
	def test_update_tasks_from_file_with_non_existent_file
		manager = TestFileManager.new('non_existent.csv')
		assert_output(/File not found/) { manager.update_tasks_from_file }
	end

	# Перевірка на те, чи open_and_validate_file повертає об'єкт файлу
	def test_open_and_validate_file_returns_file
		manager = TestFileManager.new('test_input.csv')
		File.write('test_input.csv', 'data')
		file = manager.open_and_validate_file('test_input.csv')

		assert_kind_of File, file
	ensure
		file&.close
		File.delete('test_input.csv') if File.exist?('test_input.csv') # rubocop:disable Lint/NonAtomicFileOperation
	end

	# Перевірка, чи write_tasks_to_file коректно записує дані у файлі
	def test_write_tasks_to_file_correct_writing
		manager = TestFileManager.new('test_input.csv', 'test_output.csv')
		managed_task_list = [{ start: 3, end: 4, priority: 5, resources: 6 }]
		max_sum_priority = 5

		manager.write_tasks_to_file(max_sum_priority, managed_task_list)

		content = File.read('test_output.csv')
		expected_content = "max_sum_priority: 5\nstart, end, priority, resorces\n3, 4, 5, 6\n"
		assert_equal expected_content, content
	ensure
		File.delete('test_output.csv') if File.exist?('test_output.csv') # rubocop:disable Lint/NonAtomicFileOperation
	end
end
