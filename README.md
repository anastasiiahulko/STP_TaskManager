# STP_TaskManager

_Created for the course "Stack of programming technologies" V. N. Karazin Kharkiv National University_

Ruby 3.3.5 "Task Manager".

---

The main executable file `program.rb`.

Structure of a task in `task.rb`.

Algorithm of task selection in `task_list.rb`.

The program takes the list of tasks from the file `input_tasks.csv`.
Its structure:
- **total_resources**: The first line defines the total available resources for task scheduling.
- **Task details**: The subsequent lines represent the list of tasks. Each task has the following columns:
  - `start`: The start time of the task (inclusive).
  - `end`: The end time of the task (inclusive).
  - `priority`: The priority of the task (higher numbers indicate higher priority).
  - `resources`: The number of resources required to execute the task.

The result of the selection is written to the file `output_managed_tasks.csv`.
Its structure:
- **max_sum_priority**: The first line indicates the maximum sum of task priorities that were selected, which optimizes the resource allocation based on the tasks' priorities.
- **Selected tasks**: The subsequent lines represent the list of tasks that were chosen for execution. Each task has the following columns:
  - `start`: The start time of the task (inclusive).
  - `end`: The end time of the task (inclusive).
  - `priority`: The priority of the task (higher numbers indicate higher priority).
  - `resources`: The number of resources allocated to the task.

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

> ruby program.rb input_tasks_v2.csv
# input_tasks_v2.csv
total_resources: 5
start,end,priority,resorces
1,5,10,2
2,6,20,1
3,7,5,3
# output_managed_tasks.csv
max_sum_priority: 150
start, end, priority, resorces
1, 5, 10, 2
2, 6, 20, 1

> ruby program.rb input_tasks_v3.csv
# input_tasks_v3.csv
total_resources: 3
start,end,priority,resorces
0,2,8,1
1,4,15,2
3,6,10,1
5,9,5,2
6,10,20,3
# output_managed_tasks.csv
max_sum_priority: 184
start, end, priority, resorces
0, 2, 8, 1
1, 4, 15, 2
6, 10, 20, 3

> ruby program.rb input_tasks_v4.csv
# input_tasks_v4.csv
total_resources: 3
start,end,priority,resorces
0,4,10,4
1,5,15,5
2,6,20,6
# output_managed_tasks.csv
max_sum_priority: 0
start, end, priority, resorces


```
