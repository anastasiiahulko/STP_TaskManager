# frozen_string_literal: true

require 'csv'
require_relative 'task_list'
require_relative 'task'
require_relative 'constants'

# An abstract class for managing file tasks
class FileManager

	def initialize
		raise NotImplementedError
	end

	def self.open_and_validate_file(file_path)
		unless File.exist?(file_path)
			puts("#{Constants::FILE_NOT_FOUND} File: #{output_file_path}")
			return
		end

		unless File.readable?(file_path)
			puts("#{Constants::FILE_NOT_READABLE} File: #{output_file_path}")
			return
		end

		File.open(file_path, 'r')
	end

	def self.update_tasks_from_file(file_path) # rubocop:disable Metrics/MethodLength
		file = open_and_validate_file(file_path)
		return unless file

		first_line = file.readline
		total_resources = first_line.split(':')[1].to_i
		file.close

		task_list = TaskList.new(total_resources)
		CSV.foreach(file_path, headers: true, col_sep: ',', skip_lines: /:/) do |row|
			task_list.add(Task.new(row['start'].to_i, row['end'].to_i, row['priority'].to_i, row['resorces'].to_i))
		end

		task_list
	end

	def self.write_tasks_to_file(output_file_path, max_sum_priority, managed_task_list) # rubocop:disable Metrics/MethodLength
		unless File.writable?(File.dirname(output_file_path))
			puts("#{Constants::FILE_NOT_WRITABLE} File: #{output_file_path}")
			return
		end

		File.open(output_file_path, 'w') do |file|
			file.puts "max_sum_priority: #{max_sum_priority}"

			file.puts 'start, end, priority, resorces'

			managed_task_list.each do |task|
				file.puts "#{task.t_start}, #{task.t_end}, #{task.priority}, #{task.resources}"
			end
		end
		puts("#{Constants::RESULT} #{output_file_path}")
	end
end
