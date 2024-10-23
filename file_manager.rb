# frozen_string_literal: true

require 'csv'
require_relative 'task_list'
require_relative 'task'
require_relative 'constants'

# An module for managing file tasks
module FileManager
	def self.open_and_validate_file(file_path)
		unless File.exist?(file_path)
			puts("ERROR! File not found! File: #{file_path}")
			return
		end

		unless File.readable?(file_path)
			puts("ERROR! File not readable! File: #{file_path}")
			return
		end

		File.open(file_path, 'r')
	end

	# rubocop:disable Metrics/AbcSize
	def self.update_tasks_from_file(file_path)
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
	# rubocop:enable Metrics/AbcSize

	# rubocop:disable Metrics/MethodLength
	def self.write_tasks_to_file(output_file_path, max_sum_priority, managed_task_list, name_val = 'max_sum_priority')
		unless File.writable?(File.dirname(output_file_path))
			puts("ERROR! This file is not writable! File: #{output_file_path}")
			return
		end

		File.open(output_file_path, 'w') do |file|
			file.puts "#{name_val}: #{max_sum_priority}"
			file.puts 'start, end, priority, resorces'

			managed_task_list.each do |task|
				file.puts "#{task.t_start}, #{task.t_end}, #{task.priority}, #{task.resources}"
			end
		end

		puts("The result of the selected tasks is written to a file: #{output_file_path}")
	end
	# rubocop:enable Metrics/MethodLength

	# exports array data_hashs to csv file, where headers are keys,
	def self.export_csv(data_hashs, file_path)
		CSV.open(file_path, 'wb', col_sep: ', ') do |csv|
			csv << data_hashs.last.keys
			data_hashs.each do |hash|
				csv << hash.values
			end
			puts("The result is written to a file: #{file_path}")
		end
	end
end
