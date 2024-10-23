# frozen_string_literal: true

require 'minitest/autorun'
require 'csv'
require_relative '../file_manager'
require_relative '../constants'

# testing class FileManager
class TestFileManager < Minitest::Test
	class MockFileManager < FileManager # rubocop:disable Style/Documentation
		def initialize
			super
			@file_path = Constants::DEFAULT_FILE_INPUT_PATH
			@output_file_path = Constants::DEFAULT_FILE_OUTPUT_PATH
			@total_resources = 0
			@data_rows = []
		end

		def update_tasks_from_file # rubocop:disable Metrics/MethodLength
			file = open_and_validate_file(@file_path)
			return unless file

			first_line = file.readline
			@total_resources = first_line.split(':')[1].to_i

			file.readline

			CSV.foreach(@file_path, headers: true, col_sep: ',') do |row|
				@data_rows << {
					start: row['start'].to_i,
					end: row['end'].to_i,
					priority: row['priority'].to_i,
					resources: row['resources'].to_i
				}
			end
		end

		def setup
			@file_manager = MockFileManager.new
		end

		# перевірка що при створенні екземпляру класу FileManager виникає виняток NotImplementedError
		def test_initialize
			assert_raises(NotImplementedError) { FileManager.new }
		end

		# Перевірка, що підклас можна створити
		def test_concrete_class_can_be_instantiated
			manager = TestFileManager.new
			assert_instance_of TestFileManager, manager
		end

		# Перевірка чи виводиться повідомлення FILE_NOT_FOUND, коли файл не існує
		def test_open_and_validate_file_not_exist
			File.stub(:exist?, false) do
				assert_output(/File not found/) { @file_manager.open_and_validate_file('invalid_path') }
			end
		end

		# перевірка чи виводиться повідомлення FILE_NOT_READABLE, коли файл існує, але не може бути прочитаний
		def test_open_and_validate_file_not_readable
			File.stub(:exist?, true) do
				File.stub(:readable?, false) do
					assert_output(/File not readable/) { @file_manager.open_and_validate_file('valid_path') }
				end
			end
		end

		# Перевірка успішного відкриття файлу, коли файл існує і може бути прочитаний
		def test_open_and_validate_file_success
			File.stub(:exist?, true) do
				File.stub(:readable?, true) do
					File.stub(:open, 'fake_file') do
						assert_equal 'fake_file', @file_manager.open_and_validate_file('valid_path')
					end
				end
			end
		end

		def create_test_csv_file
			File.open('test_file.csv', 'w') do |file|
				file.puts 'total_resources: 1'
				file.puts 'start,end,priority,resources'
				file.puts '1,2,3,4'
			end
		end

		def cleanup_test_csv_file
			File.delete('test_file.csv')
		end

		# Перевірка методу update_tasks_from_file, чи читає дані з CSV-файлу і чи зберігає їх у масиві data_rows
		def test_update_tasks_from_file # rubocop:disable Metrics/AbcSize,Metrics/MethodLength
			create_test_csv_file

			File.stub(:exist?, true) do
				File.stub(:readable?, true) do
					File.stub(:open, File.open('test_file.csv')) do
						@file_manager.update_tasks_from_file
						assert_equal 1, @file_manager.data_rows.first[:start]
						assert_equal 2, @file_manager.data_rows.first[:end]
						assert_equal 3, @file_manager.data_rows.first[:priority]
						assert_equal 4, @file_manager.data_rows.first[:resources]
					end
				end
			end

			cleanup_test_csv_file
		end

		# Перевірка чи виводиться повідомлення FILE_NOT_WRITABLE, коли файл не може бути записаний
		def test_write_tasks_to_file_not_writable
			max_sum_priority = 10
			managed_task_list = [{ start: 1, end: 2, priority: 3, resources: 4 }]

			File.stub(:writable?, false) do
				assert_output(/This file is not writable/) do
					@file_manager.write_tasks_to_file(max_sum_priority, managed_task_list)
				end
			end
		end

		# перевірка чи успішно записуються дані у файл за допомогою методу write_tasks_to_file
		def test_write_tasks_to_file_success
			max_sum_priority = 10
			managed_task_list = [{ start: 1, end: 2, priority: 3, resources: 4 }]

			File.stub(:writable?, true) do
				File.stub(:open, StringIO.new, [@output_file_path, 'w']) do |io|
					@file_manager.write_tasks_to_file(max_sum_priority, managed_task_list)
					assert_includes io.string, "max_sum_priority: #{max_sum_priority}"
					assert_includes io.string, 'start, end, priority, resources'
					assert_includes io.string, '1, 2, 3, 4'
				end
			end
		end
	end
end
