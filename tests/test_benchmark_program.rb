# frozen_string_literal: true

require 'benchmark'
require 'objspace'
require 'stringio'
require_relative '../constants'
require_relative '../task_list'
require_relative '../file_manager'

# rubocop:disable Metrics/AbcSize,Metrics/MethodLength
def benchmark_tasks(tasks_list)
	GC.start
	original_stdout = $stdout
	$stdout = StringIO.new
	ram_before = ObjectSpace.memsize_of_all
	time = Benchmark.bm do |x|
		x.report('report') { tasks_list.generate_task_list }
	end
	ram = ObjectSpace.memsize_of_all - ram_before
	$stdout.close
	$stdout = original_stdout
	GC.start

	{ case: '', utime: time.last.utime, stime: time.last.stime, time: time.last.total,
			rtime: time.last.real, ram_memory: ram }
end

def generate_best_tasks_list(recursion_depth, max_count, total_resources = 12, file_path = nil)
	tasks = []
	recursion_depth.times do |i|
		var = rand(1..3)
		tasks.push(Task.new(i, i, var, var))
		break if tasks.size >= max_count

		if (var % 3).zero?
			tasks.push(Task.new(i, i, var + 1, total_resources - var))
		elsif var.even?
			tasks.push(Task.new(i, i, var - 1, total_resources - var))
		end
		break if tasks.size >= max_count
	end

	FileManager.write_tasks_to_file(file_path, total_resources, tasks, 'total_resources') unless file_path.nil?

	TaskList.new(total_resources, tasks)
end

def generate_worst_tasks_list(recursion_depth, max_count, total_resources = recursion_depth / 2, file_path = nil)
	tasks = []
	recursion_depth.times do |i|
		(total_resources - 1).times do
			tasks.push(Task.new(i, i + 3, 1, total_resources - 1))
			break if tasks.size >= max_count
		end
		break if tasks.size >= max_count
	end

	FileManager.write_tasks_to_file(file_path, total_resources, tasks, 'total_resources') unless file_path.nil?

	TaskList.new(total_resources, tasks)
end

def generate_random_tasks_list(recursion_depth, max_count, total_resources = recursion_depth / 2, file_path = nil)
	tasks = []
	recursion_depth.times do |i|
		var = rand(1..total_resources)
		tasks.push(Task.new(i, i, var, var))
		(var - 1).times do
			tasks.push(Task.new(i, rand(i..recursion_depth), rand(0..total_resources), rand(0..total_resources)))
			break if tasks.size >= max_count
		end
		break if tasks.size >= max_count
	end

	FileManager.write_tasks_to_file(file_path, total_resources, tasks, 'total_resources') unless file_path.nil?

	TaskList.new(total_resources, tasks)
end
# rubocop:enable Metrics/AbcSize, Metrics/MethodLength

puts('Start benchmark')

dep_recursions = 3
dep_recursions_best = 8
total_resources = 6
max_count = 15
result_benchmark = []
default_tasks_list = FileManager.update_tasks_from_file(Constants::DEFAULT_FILE_INPUT_PATH)
best_tasks_list = FileManager.update_tasks_from_file(Constants::BEST_FILE_INPUT_PATH)
worst_tasks_list = FileManager.update_tasks_from_file(Constants::WORST_FILE_INPUT_PATH)

if best_tasks_list.nil?
	best_tasks_list = generate_best_tasks_list(dep_recursions_best, max_count, total_resources,
													Constants::BEST_FILE_INPUT_PATH) # rubocop:disable Layout/ArgumentAlignment
end

if worst_tasks_list.nil?
	worst_tasks_list = generate_worst_tasks_list(dep_recursions, max_count, total_resources,
													Constants::WORST_FILE_INPUT_PATH) # rubocop:disable Layout/ArgumentAlignment
end

random_tasks_lists = []
random_tasks_lists.push(generate_random_tasks_list(dep_recursions, max_count,
													total_resources, Constants::RANDOM_FILE_INPUT_PATH)) # rubocop:disable Layout/ArgumentAlignment
(dep_recursions * 5).times do
	random_tasks_lists.push(generate_random_tasks_list(dep_recursions, max_count, total_resources))
end

puts("depth of recursions: #{dep_recursions} (best: #{dep_recursions_best})," \
					"total_resources: #{total_resources}, max_count: #{max_count}")
puts("case\tuser\tsystem\ttotal\treal\tram_memory")

unless default_tasks_list.nil?
	result_benchmark.push(benchmark_tasks(default_tasks_list))
	result_benchmark.last[:case] = 'default'
	puts(result_benchmark.last.values.join(', '))
end

result_benchmark.push(benchmark_tasks(best_tasks_list))
result_benchmark.last[:case] = 'best'
puts(result_benchmark.last.values.join(', '))

result_benchmark.push(benchmark_tasks(worst_tasks_list))
result_benchmark.last[:case] = 'worst'
puts(result_benchmark.last.values.join(', '))

random_tasks_lists.each do |tasks_list|
	result_benchmark.push(benchmark_tasks(tasks_list))
	result_benchmark.last[:case] = 'random'
	# puts("#{result_benchmark.size} #{result_benchmark.last[:rtime]}")
end

average = { case: 0, utime: 0, stime: 0, time: 0, rtime: 0, ram_memory: 0 }
result_benchmark.each do |hash|
	average[:utime] += hash[:utime]
	average[:stime] += hash[:stime]
	average[:time]  += hash[:time]
	average[:rtime] += hash[:rtime]
	average[:ram_memory] += hash[:ram_memory]
end

average = average.transform_values { |sum| sum / result_benchmark.size.to_f }
average[:case] = 'average'
puts(average.values.join(', '))
result_benchmark.push(average)

FileManager.export_csv(result_benchmark, Constants::BENCHMARK_FILE_OUTPUT_PATH)

puts('Stop benchmark')
