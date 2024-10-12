# STP_TaskManager

_Created for the course "Stack of programming technologies" V. N. Karazin Kharkiv National University_

Ruby 3.3.5 "Task Manager".

---

The main executable file `program.rb`.

Structure of a task in `task.rb`.

Algorithm of task selection in `task_list.rb`.

The program takes the list of tasks from the file `input_tasks.csv`.
Its structure:

The result of the selection is written to the file `output_managed_tasks.csv`.
Its structure:

Selection algorithm:

A set of tasks is selected so that the sum of priorities for each hour of execution is maximized, if there are several such combinations, the first one with the most tasks is selected

The program supports entering the path of the input file using command line arguments.

# Examples

```ruby
> ruby program.rb
# input_tasks.csv
total_resources: 5
start,end,priority,resorces
1,4,5,3
3,5,1,2
0,6,8,4
4,7,4,1
3,8,6,5
5,9,2,3
6,10,7,2
8,11,3,1
# output_managed_tasks.csv
max_sum_priority: 84
start, end, priority, resorces
0, 6, 8, 4
4, 7, 4, 1
8, 11, 3, 1

> ruby program.rb


```
