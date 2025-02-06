import 'package:flutter/material.dart';
import 'package:guul_side/screens/analytics_screen.dart';
import 'package:guul_side/screens/categories_screen.dart';
import 'package:guul_side/screens/dashboard_screen.dart';
import 'package:guul_side/screens/new_task_screen.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';
import '../widgets/task_icon.dart';
import '../theme/app_theme.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  TasksScreenState createState() => TasksScreenState();
}

class TasksScreenState extends State<TasksScreen> {
  String activeTab = 'pending';
  String filterOption = 'All';
  String searchTerm = '';
  bool isSearchVisible = false;
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<TaskController>(context, listen: false).loadTasks();
    });
  }

  List<Task> filterTasks(List<Task> tasks) {
    return tasks.where((task) {
      final matchesTab = (activeTab == 'pending' && !task.completed) ||
          (activeTab == 'completed' && task.completed);
      final matchesSearch =
          task.name.toLowerCase().contains(searchTerm.toLowerCase());

      DateTime? taskDate;
      try {
        taskDate = DateTime.parse(task.startDate);
      } catch (e) {
        print('Invalid date format for task: ${task.name}');
        return false;
      }

      final today = DateTime.now();
      final isToday = taskDate.year == today.year &&
          taskDate.month == today.month &&
          taskDate.day == today.day;
      final isThisWeek =
          taskDate.isAfter(today.subtract(const Duration(days: 7))) &&
              taskDate.isBefore(today.add(const Duration(days: 1)));
      final isThisMonth =
          taskDate.year == today.year && taskDate.month == today.month;

      final matchesFilter = filterOption == 'All' ||
          (filterOption == 'Today' && isToday) ||
          (filterOption == 'This Week' && isThisWeek) ||
          (filterOption == 'This Month' && isThisMonth);

      return matchesTab && matchesSearch && matchesFilter;
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TaskController>(
      builder: (context, taskProvider, child) {
        List<Task> filteredTasks = filterTasks(taskProvider.tasks);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Tasks'),
            backgroundColor: const Color(0xFF40E0D0),
            actions: [
              IconButton(
                icon: Icon(isSearchVisible ? Icons.close : Icons.search),
                onPressed: () {
                  setState(() {
                    isSearchVisible = !isSearchVisible;
                    if (!isSearchVisible) searchTerm = '';
                  });
                },
                tooltip: isSearchVisible ? 'Close search' : 'Search tasks',
              ),
            ],
          ),
          body: Column(
            children: [
              if (isSearchVisible)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    onChanged: (value) {
                      setState(() {
                        searchTerm = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText: 'Search tasks...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      filled: true,
                      fillColor: Colors.grey[200],
                    ),
                  ),
                ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildTabButton('pending', 'Pending tasks'),
                    _buildTabButton('completed', 'Completed Tasks'),
                  ],
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Row(
                    children: ['All', 'Today', 'This Week', 'This Month']
                        .map((option) => _buildFilterChip(option))
                        .toList(),
                  ),
                ),
              ),
              Expanded(
                child: filteredTasks.isEmpty
                    ? Center(
                        child: Text(
                          'No tasks found',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      )
                    : ListView.builder(
                        itemCount: filteredTasks.length,
                        itemBuilder: (context, index) {
                          return _buildTaskListItem(
                              filteredTasks[index], taskProvider);
                        },
                      ),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const NewTaskScreen()),
              );
            },
            backgroundColor: const Color(0xFF40E0D0),
            child: const Icon(Icons.add),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -5),
                ),
              ],
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              type: BottomNavigationBarType.fixed,
              backgroundColor: Colors.white,
              selectedItemColor: const Color(0xFF40E0D0),
              unselectedItemColor: Colors.grey,
              items: const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.home_outlined),
                  activeIcon: Icon(Icons.home),
                  label: 'Home',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.list_outlined),
                  activeIcon: Icon(Icons.list),
                  label: 'Tasks',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.grid_view_outlined),
                  activeIcon: Icon(Icons.grid_view),
                  label: 'Categories',
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.bar_chart_outlined),
                  activeIcon: Icon(Icons.bar_chart),
                  label: 'Analytics',
                ),
              ],
              onTap: (index) {
                setState(() => _currentIndex = index);
                switch (index) {
                  case 0:
                    Navigator.pushReplacementNamed(context, '/dashboard');
                    break;
                  case 2:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CategoriesScreen()),
                    );
                    break;
                  case 3:
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const AnalyticsScreen()),
                    );
                    break;
                }
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildTabButton(String tab, String label) {
    return TextButton(
      onPressed: () => setState(() => activeTab = tab),
      style: TextButton.styleFrom(
        foregroundColor:
            activeTab == tab ? const Color(0xFF40E0D0) : Colors.grey,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildFilterChip(String option) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(option),
        selected: filterOption == option,
        onSelected: (selected) {
          if (selected) {
            setState(() => filterOption = option);
          }
        },
        selectedColor: const Color(0xFF40E0D0).withOpacity(0.2),
      ),
    );
  }

  Widget _buildTaskListItem(Task task, TaskController taskProvider) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: ListTile(
        leading: TaskIcon(
          icon: task.category.icon,
          color: task.category.color,
        ),
        title: Text(
          task.name,
          style: TextStyle(
            decoration: task.completed ? TextDecoration.lineThrough : null,
          ),
        ),
        subtitle: Text(
          'Due: ${_formatDate(task.startDate)}',
          style: TextStyle(color: _getDueDateColor(task.startDate)),
        ),
        trailing: Checkbox(
          value: task.completed,
          onChanged: (bool? value) async {
            try {
              await taskProvider.toggleTaskCompletion(task.id);
            } catch (e) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error updating task: ${e.toString()}')),
              );
            }
          },
          activeColor: const Color(0xFF40E0D0),
        ),
        onTap: () => _showTaskDetails(context, task),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
    } catch (e) {
      return 'Invalid date';
    }
  }

  Color _getDueDateColor(String dateString) {
    try {
      final dueDate = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = dueDate.difference(now).inDays;

      if (difference < 0) {
        return Colors.red;
      } else if (difference == 0) {
        return Colors.orange;
      } else if (difference <= 3) {
        return Colors.yellow[700]!;
      } else {
        return Colors.green;
      }
    } catch (e) {
      return Colors.grey;
    }
  }

  void _showTaskDetails(BuildContext context, Task task) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Task ${task.id}'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Name: ${task.name}'),
                const SizedBox(height: 8),
                Text('Due Date: ${_formatDate(task.startDate)}'),
                const SizedBox(height: 8),
                Text('Priority: ${task.priority.value}'),
                const SizedBox(height: 8),
                Text('Category: ${task.category.name}'),
                const SizedBox(height: 8),
                Text('Note: ${task.note}'),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }
}
