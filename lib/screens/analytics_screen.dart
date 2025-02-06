import 'package:flutter/material.dart';
import 'package:guul_side/screens/categories_screen.dart';
import 'package:guul_side/screens/tasks_screen.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:guul_side/controllers/task_controller.dart';
import 'package:guul_side/models/task.dart';
import 'package:guul_side/theme/app_theme.dart';

class AnalyticsScreen extends StatelessWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskController>(context);
    final tasks = taskProvider.tasks;

    final completedTasks = tasks.where((task) => task.completed).toList();
    final completionRate =
        tasks.isNotEmpty ? completedTasks.length / tasks.length : 0.0;

    final categoryData = _getCategoryData(tasks);

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Analytics',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCompletionRateCard(completionRate),
                const SizedBox(height: 24),
                _buildCategoryDistributionChart(categoryData),
                const SizedBox(height: 24),
                _buildCategoryCompletionRates(categoryData),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomNavigationBar(context),
    );
  }

  Widget _buildCompletionRateCard(double completionRate) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Overall Completion Rate',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                CircularPercentIndicator(
                  radius: 60.0,
                  lineWidth: 10.0,
                  percent: completionRate,
                  center: Text(
                    '${(completionRate * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor),
                  ),
                  progressColor: AppTheme.primaryColor,
                  backgroundColor: AppTheme.surfaceColor,
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildStatItem(Icons.check_circle_outline, 'Completed',
                        '${(completionRate * 100).toStringAsFixed(1)}%'),
                    const SizedBox(height: 12),
                    _buildStatItem(Icons.pending_actions, 'Pending',
                        '${((1 - completionRate) * 100).toStringAsFixed(1)}%'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: AppTheme.primaryColor, size: 24),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: TextStyle(fontSize: 14, color: AppTheme.subtitleColor)),
            Text(value,
                style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textColor)),
          ],
        ),
      ],
    );
  }

  Widget _buildCategoryDistributionChart(
      Map<String, Map<String, int>> categoryData) {
    final pieChartData = categoryData.entries.map((entry) {
      return PieChartSectionData(
        color: _getCategoryColor(entry.key),
        value: entry.value['total']!.toDouble(),
        title: entry.key,
        radius: 50,
        titleStyle: const TextStyle(
            fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white),
      );
    }).toList();

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Distribution',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 250,
              child: PieChart(
                PieChartData(
                  sections: pieChartData,
                  sectionsSpace: 2,
                  centerSpaceRadius: 40,
                  startDegreeOffset: -90,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: categoryData.entries.map((entry) {
                return _buildLegendItem(
                    entry.key, _getCategoryColor(entry.key));
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: TextStyle(fontSize: 12, color: AppTheme.textColor)),
      ],
    );
  }

  Widget _buildCategoryCompletionRates(
      Map<String, Map<String, int>> categoryData) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Category Completion Rates',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textColor),
            ),
            const SizedBox(height: 20),
            ...categoryData.entries.map((entry) {
              final completionRate = entry.value['total'] != 0
                  ? entry.value['completed']! / entry.value['total']!
                  : 0.0;
              return Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(entry.key,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppTheme.textColor)),
                        Text(
                          '${(completionRate * 100).toStringAsFixed(1)}%',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: _getCategoryColor(entry.key),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: completionRate,
                        backgroundColor: AppTheme.surfaceColor,
                        valueColor: AlwaysStoppedAnimation<Color>(
                            _getCategoryColor(entry.key)),
                        minHeight: 8,
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        currentIndex: 3,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        selectedItemColor: AppTheme.primaryColor,
        unselectedItemColor: AppTheme.subtitleColor,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.list_outlined),
              activeIcon: Icon(Icons.list),
              label: 'Tasks'),
          BottomNavigationBarItem(
              icon: Icon(Icons.category_outlined),
              activeIcon: Icon(Icons.category),
              label: 'Categories'),
          BottomNavigationBarItem(
              icon: Icon(Icons.bar_chart_outlined),
              activeIcon: Icon(Icons.bar_chart),
              label: 'Analytics'),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushReplacementNamed(context, '/dashboard');
              break;
            case 1:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const TasksScreen()),
              );
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CategoriesScreen()),
              );
              break;
          }
        },
      ),
    );
  }

  Map<String, Map<String, int>> _getCategoryData(List<Task> tasks) {
    final categoryData = <String, Map<String, int>>{};
    for (final task in tasks) {
      final category = task.category.name;
      if (!categoryData.containsKey(category)) {
        categoryData[category] = {'total': 0, 'completed': 0};
      }
      categoryData[category]!['total'] =
          (categoryData[category]!['total'] ?? 0) + 1;
      if (task.completed) {
        categoryData[category]!['completed'] =
            (categoryData[category]!['completed'] ?? 0) + 1;
      }
    }
    return categoryData;
  }

  Color _getCategoryColor(String category) {
    final colorMap = {
      'Work': const Color(0xFF4CAF50),
      'Personal': const Color(0xFF2196F3),
      'Study': const Color(0xFFFFC107),
      'Health': const Color(0xFFE91E63),
      'Social': const Color(0xFF9C27B0),
      'Other': const Color(0xFF795548),
      'Finance': const Color.fromARGB(255, 198, 198, 5),
    };
    return colorMap[category] ?? AppTheme.primaryColor;
  }
}

class CircularPercentIndicator extends StatelessWidget {
  final double radius;
  final double lineWidth;
  final double percent;
  final Widget center;
  final Color progressColor;
  final Color backgroundColor;

  const CircularPercentIndicator({
    Key? key,
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.center,
    required this.progressColor,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CircularPercentPainter(
        radius: radius,
        lineWidth: lineWidth,
        percent: percent,
        progressColor: progressColor,
        backgroundColor: backgroundColor,
      ),
      child: SizedBox(
        width: radius * 2,
        height: radius * 2,
        child: Center(child: center),
      ),
    );
  }
}

class _CircularPercentPainter extends CustomPainter {
  final double radius;
  final double lineWidth;
  final double percent;
  final Color progressColor;
  final Color backgroundColor;

  _CircularPercentPainter({
    required this.radius,
    required this.lineWidth,
    required this.percent,
    required this.progressColor,
    required this.backgroundColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = backgroundColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth;

    final progressPaint = Paint()
      ..color = progressColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = lineWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(center, radius, backgroundPaint);
    canvas.drawArc(rect, -90 * (3.14159 / 180), percent * 360 * (3.14159 / 180),
        false, progressPaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
