# frozen_string_literal: true

require_relative 'constants'
require_relative 'task_list'
require_relative 'file_manager'

puts(Constants::AUTHOR)

file_path = Constants::DEFAULT_FILE_INPUT_PATH
file_path = ARGV[0] unless ARGV.empty?

tasks_list = FileManager.update_tasks_from_file(file_path)

sum_priority, result_task_list = tasks_list.generate_task_list

FileManager.write_tasks_to_file(Constants::DEFAULT_FILE_OUTPUT_PATH, sum_priority, result_task_list)
