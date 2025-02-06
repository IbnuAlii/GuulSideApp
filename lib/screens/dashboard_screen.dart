import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guul_side/screens/tasks_screen.dart';
import 'package:guul_side/controllers/task_controller.dart';
import 'package:guul_side/controllers/auth_controller.dart';
import 'package:guul_side/widgets/task_item.dart';
import 'package:guul_side/screens/new_task_screen.dart';
import 'package:guul_side/screens/categories_screen.dart';
import 'package:guul_side/screens/analytics_screen.dart';
import 'package:guul_side/screens/profile_screen.dart';
import 'package:guul_side/widgets/sidebar_menu.dart';
import 'package:guul_side/models/task.dart';

class DashboardScreen extends GetView<TaskController> {
  DashboardScreen({Key? key}) : super(key: key);

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final AuthController _authController = Get.find<AuthController>();

  final Rx<DateTime> _selectedDate = DateTime.now().obs;
  final RxBool _showInfo = false.obs;
  final RxBool _isSearchVisible = false.obs;
  final RxString _searchTerm = ''.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: Colors.white,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverToBoxAdapter(child: _buildAppBar()),
            SliverToBoxAdapter(child: _buildDatePicker()),
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.only(left: 16, top: 24, bottom: 16),
                child: Text(
                  'Tasks',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SliverFillRemaining(
              child: _buildTaskList(),
            ),
          ],
        ),
      ),
      floatingActionButton: _buildFloatingActionButton(),
      bottomNavigationBar: _buildBottomNavBar(),
      drawer: const SidebarMenu(),
    );
  }

  Widget _buildAppBar() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () {
              _scaffoldKey.currentState?.openDrawer();
            },
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          Expanded(
            child: Obx(() {
              return _isSearchVisible.value
                  ? TextField(
                      onChanged: (value) {
                        _searchTerm.value = value;
                      },
                      decoration: InputDecoration(
                        hintText: 'Search tasks...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                      ),
                    )
                  : const Text(
                      "Today's Schedule",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    );
            }),
          ),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _isSearchVisible.toggle();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              IconButton(
                icon: const Icon(Icons.info_outline),
                onPressed: () {
                  _showInfo.toggle();
                },
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
              const SizedBox(width: 16),
              Obx(() => GestureDetector(
                    onTap: () => Get.to(() => const ProfileScreen()),
                    child: CircleAvatar(
                      radius: 16,
                      backgroundImage: _authController.user?.imageUrl != null
                          ? NetworkImage(_authController.user!.imageUrl!)
                          : null,
                      child: _authController.user?.imageUrl == null
                          ? const Icon(Icons.person, size: 20)
                          : null,
                    ),
                  )),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDatePicker() {
    return Obx(() {
      final now = DateTime.now();
      final dates = List.generate(
        7,
        (index) => now.subtract(Duration(days: now.weekday - index - 3)),
      );

      return Container(
        height: 90,
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: dates.length,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemBuilder: (context, index) {
            final date = dates[index];
            final isSelected = date.day == _selectedDate.value.day &&
                date.month == _selectedDate.value.month &&
                date.year == _selectedDate.value.year;

            return GestureDetector(
              onTap: () => _selectedDate.value = date,
              child: Container(
                width: 60,
                margin: const EdgeInsets.symmetric(horizontal: 4),
                decoration: BoxDecoration(
                  color:
                      isSelected ? const Color(0xFF40E0D0) : Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      _getDayName(date.weekday),
                      style: TextStyle(
                        fontSize: 12,
                        color: isSelected ? Colors.white70 : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString(),
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isSelected ? Colors.white : Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      );
    });
  }

  String _getDayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Mon';
      case DateTime.tuesday:
        return 'Tue';
      case DateTime.wednesday:
        return 'Wed';
      case DateTime.thursday:
        return 'Thu';
      case DateTime.friday:
        return 'Fri';
      case DateTime.saturday:
        return 'Sat';
      case DateTime.sunday:
        return 'Sun';
      default:
        return '';
    }
  }

  Widget _buildTaskList() {
    return Obx(() {
      final filteredTasks = controller.tasks.where((task) {
        // Filter by search term
        final matchesSearch =
            task.name.toLowerCase().contains(_searchTerm.value.toLowerCase());

        // Filter by selected date
        final taskStartDate = DateTime.parse(task.startDate);
        final taskEndDate = DateTime.parse(task.endDate);
        final selectedDateTime = DateTime(_selectedDate.value.year,
            _selectedDate.value.month, _selectedDate.value.day);
        final isOnSelectedDate = selectedDateTime.isAtSameMomentAs(DateTime(
                taskStartDate.year, taskStartDate.month, taskStartDate.day)) ||
            (selectedDateTime.isAfter(taskStartDate) &&
                selectedDateTime.isBefore(taskEndDate)) ||
            selectedDateTime.isAtSameMomentAs(
                DateTime(taskEndDate.year, taskEndDate.month, taskEndDate.day));

        return matchesSearch && isOnSelectedDate;
      }).toList();

      if (filteredTasks.isEmpty) {
        return Center(
          child: Text(
            'No tasks for ${_selectedDate.value.day}/${_selectedDate.value.month}/${_selectedDate.value.year}',
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        );
      }

      return ListView.builder(
        itemCount: filteredTasks.length,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemBuilder: (context, index) {
          return TaskItem(task: filteredTasks[index]);
        },
      );
    });
  }

  Widget _buildFloatingActionButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF40E0D0).withOpacity(0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: () => Get.to(() => const NewTaskScreen()),
        backgroundColor: const Color(0xFF40E0D0),
        child: const Icon(Icons.add),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
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
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 0,
        selectedItemColor: const Color(0xFF40E0D0),
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
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
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0,
        onTap: (index) {
          switch (index) {
            case 1:
              Get.to(() => const TasksScreen());
              break;
            case 2:
              Get.to(() => const CategoriesScreen());
              break;
            case 3:
              Get.to(() => const AnalyticsScreen());
              break;
            case 4:
              Get.to(() => const ProfileScreen());
              break;
          }
        },
      ),
    );
  }
}
