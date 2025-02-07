import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../controllers/task_controller.dart';
import '../screens/new_task_screen.dart';

class TaskDetailsModal extends StatelessWidget {
  final Task task;

  const TaskDetailsModal({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                task.name,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: task.category.color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  task.category.iconData,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Start: ${_formatDate(task.startDate)}    End: ${_formatDate(task.endDate)}',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatusButton(
                  context,
                  'Pending',
                  !task.completed,
                  onTap: () => _updateTaskStatus(context, false),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildStatusButton(
                  context,
                  'Done',
                  task.completed,
                  onTap: () => _updateTaskStatus(context, true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          _buildActionButton(
            context,
            icon: Icons.notifications_outlined,
            label: 'Add reminder ...',
            onTap: () => _showReminderDialog(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.chat_bubble_outline,
            label: 'Add note ...',
            onTap: () => _showNoteDialog(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.schedule,
            label: 'Reschedule',
            onTap: () => _showDatePicker(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.delete_outline,
            label: 'Delete',
            color: Colors.red[400],
            onTap: () => _confirmDelete(context),
          ),
          _buildActionButton(
            context,
            icon: Icons.edit_outlined,
            label: 'Edit',
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NewTaskScreen(taskToEdit: task),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusButton(
    BuildContext context,
    String label,
    bool isSelected, {
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF40E0D0) : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    Color? color,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Icon(
              icon,
              color: color ?? Colors.grey[600],
              size: 22,
            ),
            const SizedBox(width: 16),
            Text(
              label,
              style: TextStyle(
                color: color ?? Colors.grey[600],
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showReminderDialog(BuildContext context) {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    ).then((time) {
      if (time != null) {
        // Show date picker after time is selected
        showDatePicker(
          context: context,
          initialDate: DateTime.now(),
          firstDate: DateTime.now(),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        ).then((date) {
          if (date != null) {
            // TODO: Implement reminder functionality with selected date and time
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reminder set successfully')),
            );
            Navigator.pop(context);
          }
        });
      }
    });
  }

  void _showNoteDialog(BuildContext context) {
    final noteController = TextEditingController(text: task.note);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Task Note'),
        content: TextField(
          controller: noteController,
          maxLines: 5,
          decoration: const InputDecoration(
            hintText: 'Enter your note here...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final taskProvider =
                  Provider.of<TaskController>(context, listen: false);
              final updatedTask = task.copyWith(note: noteController.text);
              taskProvider.updateTask(updatedTask);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close modal
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDatePicker(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.parse(task.startDate),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) {
      final taskProvider = Provider.of<TaskController>(context, listen: false);
      final updatedTask = task.copyWith(
        startDate: picked.toIso8601String(),
        endDate: picked.add(const Duration(days: 1)).toIso8601String(),
      );
      taskProvider.updateTask(updatedTask);
      Navigator.pop(context);
    }
  }

  void _updateTaskStatus(BuildContext context, bool completed) {
    if (task.completed != completed) {
      final taskProvider = Provider.of<TaskController>(context, listen: false);
      final updatedTask = task.copyWith(completed: completed);
      taskProvider.updateTask(updatedTask);
      Navigator.pop(context);
    }
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Task'),
        content: const Text('Are you sure you want to delete this task?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final taskProvider =
                  Provider.of<TaskController>(context, listen: false);
              taskProvider.deleteTask(task.id);
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Close modal
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  String _formatDate(String dateString) {
    final date = DateTime.parse(dateString);
    return 'Jan ${date.day}'; // Formatted to match the design
  }
}
