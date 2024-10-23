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
  - `start`: The start time of the task (including).
  - `end`: The end time of the task (not including).
  - `priority`: The priority of the task (higher numbers indicate higher priority).
  - `resources`: The number of resources required to execute the task.

The result of the selection is written to the file `output_managed_tasks.csv`.
Its structure:

- **max_sum_priority**: The first line indicates the maximum sum of task priorities that were selected, which optimizes the resource allocation based on the tasks' priorities.
- **Selected tasks**: The subsequent lines represent the list of tasks that were chosen for execution. Each task has the following columns:
  - `start`: The start time of the task (including).
  - `end`: The end time of the task (not including).
  - `priority`: The priority of the task (higher numbers indicate higher priority).
  - `resources`: The number of resources allocated to the task.

Selection algorithm:

The program recursively selects a set of tasks using the branch and bound method to maximize the total sum of priorities while not exceeding the available resources.

The program supports entering the path of the input file using command line arguments.

All tests and benchmarks are located in the `tests` folder.

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
max_sum_priority: 22
start, end, priority, resorces
0, 6, 8, 4
4, 7, 4, 1
6, 10, 7, 2
8, 11, 3, 1

> ruby program.rb input_tasks_v2.csv
# input_tasks_v2.csv
total_resources: 5
start,end,priority,resorces
1,5,10,2
2,6,20,1
3,7,5,3
# output_managed_tasks.csv
max_sum_priority: 30
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
5,9,5,3
6,10,20,3
# output_managed_tasks.csv
max_sum_priority: 53
start, end, priority, resorces
0, 2, 8, 1
1, 4, 15, 2
3, 6, 10, 1
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

> ruby program.rb input_tasks_v5.csv
# input_tasks_v5.csv
total_resources: 3
start,end,priority,resorces
0,4,10,2
1,3,20,1
2,5,30,3
4,6,25,2
# output_managed_tasks.csv
max_sum_priority: 55
start, end, priority, resorces
0, 4, 10, 2
1, 3, 20, 1
4, 6, 25, 2

> ruby program.rb input_tasks_v6.csv
# input_tasks_v6.csv
total_resources: 5
start,end,priority,resorces
0,3,8,2
1,4,10,3
3,5,12,2
2,6,20,4
5,8,18,3
# output_managed_tasks.csv
max_sum_priority: 48
start, end, priority, resorces
0, 3, 8, 2
1, 4, 10, 3
3, 5, 12, 2
5, 8, 18, 3

> ruby program.rb input_tasks_v7.csv
# input_tasks_v7.csv
total_resources: 5
start,end,priority,resorces
1,4,10,3
2,6,20,4
8,12,18,3
# output_managed_tasks.csv
max_sum_priority: 38
start, end, priority, resorces
2, 6, 20, 4
8, 12, 18, 3

> ruby program.rb input_tasks_v8.csv
# input_tasks_v8.csv
total_resources: 5
start,end,priority,resorces
0,4,20,4
0,3,1,3
1,4,5,1
1,3,1,2
2,4,1,4
3,4,23,5
# output_managed_tasks.csv
max_sum_priority: 25
start, end, priority, resorces
0, 3, 1, 3
1, 3, 1, 2
3, 4, 23, 5
```
