import 'package:flutter/material.dart';
import 'package:guul_side/widgets/category_modal.dart' as category_selector;
import 'package:guul_side/widgets/priority_modal.dart';
import 'package:provider/provider.dart';
import '../controllers/task_controller.dart';
import '../models/task.dart' as task_model;
import '../models/category.dart' as category_model;
import '../theme/app_theme.dart';

class NewTaskScreen extends StatefulWidget {
  final task_model.Task? taskToEdit;
  final category_model.Category? initialCategory;

  const NewTaskScreen({
    Key? key,
    this.taskToEdit,
    this.initialCategory,
  }) : super(key: key);

  @override
  NewTaskScreenState createState() => NewTaskScreenState();
}

class NewTaskScreenState extends State<NewTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _taskNameController;
  late TextEditingController _taskNoteController;
  late DateTime _startDate;
  late DateTime _endDate;
  task_model.Category? _selectedCategory;
  late task_model.Priority _selectedPriority;
  DateTime? _reminderTime;

  @override
  void initState() {
    super.initState();
    _taskNameController = TextEditingController(text: widget.taskToEdit?.name);
    _taskNoteController = TextEditingController(text: widget.taskToEdit?.note);
    _startDate = widget.taskToEdit != null
        ? DateTime.parse(widget.taskToEdit!.startDate)
        : DateTime.now();
    _endDate = widget.taskToEdit != null
        ? DateTime.parse(widget.taskToEdit!.endDate)
        : DateTime.now().add(const Duration(days: 1));
    _selectedCategory =
        widget.taskToEdit?.category ?? _convertCategory(widget.initialCategory);
    _selectedPriority = widget.taskToEdit?.priority ??
        task_model.Priority(value: 1, isDefault: true);
    _reminderTime = widget.taskToEdit?.reminder != null
        ? DateTime.parse(widget.taskToEdit!.reminder!)
        : null;
  }

  task_model.Category? _convertCategory(category_model.Category? category) {
    if (category == null) return null;
    return task_model.Category(
      name: category.name,
      icon: category.icon,
      color: category.color,
    );
  }

  @override
  void dispose() {
    _taskNameController.dispose();
    _taskNoteController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: isStartDate ? _startDate : _endDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppTheme.primaryColor,
            colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _endDate = _startDate.add(const Duration(days: 1));
          }
        } else {
          _endDate = picked;
          if (_endDate.isBefore(_startDate)) {
            _startDate = _endDate.subtract(const Duration(days: 1));
          }
        }
      });
    }
  }

  void _showCategorySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => category_selector.CategorySelector(
        selectedCategory: _selectedCategory != null
            ? category_model.Category(
                name: _selectedCategory!.name,
                icon: _selectedCategory!.icon,
                color: _selectedCategory!.color,
              )
            : null,
        onCategorySelected: (category) {
          setState(() => _selectedCategory = task_model.Category(
                name: category.name,
                icon: category.icon,
                color: category.color,
              ));
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showPrioritySelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => PrioritySelector(
        selectedPriority: _selectedPriority,
        onPriorityChanged: (priority) {
          setState(() => _selectedPriority = priority);
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showReminderSelector() {
    showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppTheme.primaryColor,
            colorScheme: ColorScheme.light(primary: AppTheme.primaryColor),
            buttonTheme:
                const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    ).then((selectedTime) {
      if (selectedTime != null) {
        setState(() {
          _reminderTime = DateTime(
            _startDate.year,
            _startDate.month,
            _startDate.day,
            selectedTime.hour,
            selectedTime.minute,
          );
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surfaceColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.taskToEdit != null ? 'Edit Task' : 'New Task',
          style: const TextStyle(
            color: AppTheme.textColor,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildTaskNameInput(),
            const SizedBox(height: 32),
            _buildCategorySelector(),
            const SizedBox(height: 24),
            _buildDateSelector(),
            const SizedBox(height: 24),
            _buildReminderSelector(),
            const SizedBox(height: 24),
            _buildPrioritySelector(),
            const SizedBox(height: 24),
            _buildNoteInput(),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildTaskNameInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _taskNameController,
        style: const TextStyle(fontSize: 18),
        decoration: InputDecoration(
          hintText: 'What would you like to do?',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter a task name';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildCategorySelector() {
    return _buildSelectorTile(
      icon: Icons.category_outlined,
      title: 'Category',
      trailing: _selectedCategory == null
          ? const Icon(Icons.chevron_right)
          : Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  category_model.Category.getIconData(_selectedCategory!.icon),
                  color: _selectedCategory!.color,
                ),
                const SizedBox(width: 8),
                Text(_selectedCategory!.name),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right),
              ],
            ),
      onTap: _showCategorySelector,
    );
  }

  Widget _buildDateSelector() {
    return _buildSelectorTile(
      icon: Icons.calendar_today_outlined,
      title: 'Date',
      trailing: Text(
        '${_startDate.toString().split(' ')[0]} - ${_endDate.toString().split(' ')[0]}',
        style: const TextStyle(color: AppTheme.textColor),
      ),
      onTap: () async {
        await _selectDate(true);
        await _selectDate(false);
      },
    );
  }

  Widget _buildReminderSelector() {
    return _buildSelectorTile(
      icon: Icons.notifications_outlined,
      title: 'Reminder',
      trailing: Text(
        _reminderTime != null
            ? '${_reminderTime!.hour.toString().padLeft(2, '0')}:${_reminderTime!.minute.toString().padLeft(2, '0')}'
            : 'Not set',
        style: const TextStyle(color: AppTheme.textColor),
      ),
      onTap: _showReminderSelector,
    );
  }

  Widget _buildPrioritySelector() {
    return _buildSelectorTile(
      icon: Icons.flag_outlined,
      title: 'Priority',
      trailing: Text(
        'Priority ${_selectedPriority.value}',
        style: const TextStyle(color: AppTheme.textColor),
      ),
      onTap: _showPrioritySelector,
    );
  }

  Widget _buildNoteInput() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TextFormField(
        controller: _taskNoteController,
        maxLines: 5,
        style: const TextStyle(fontSize: 16),
        decoration: InputDecoration(
          hintText: 'Add a note...',
          border: InputBorder.none,
          hintStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),
    );
  }

  Widget _buildSelectorTile({
    required IconData icon,
    required String title,
    required Widget trailing,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: ListTile(
        leading: Icon(icon, color: AppTheme.primaryColor),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppTheme.textColor,
          ),
        ),
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                foregroundColor: AppTheme.textColor,
                backgroundColor: Colors.grey[200],
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('CANCEL',
                  style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () async {
                if (_formKey.currentState!.validate() &&
                    _selectedCategory != null) {
                  final taskProvider =
                      Provider.of<TaskController>(context, listen: false);
                  final task = task_model.Task(
                    id: widget.taskToEdit?.id ?? '',
                    name: _taskNameController.text,
                    category: _selectedCategory!,
                    startDate: _startDate.toIso8601String(),
                    endDate: _endDate.toIso8601String(),
                    priority: _selectedPriority,
                    note: _taskNoteController.text,
                    completed: widget.taskToEdit?.completed ?? false,
                    reminder: _reminderTime?.toIso8601String(),
                  );

                  try {
                    if (widget.taskToEdit != null) {
                      await taskProvider.updateTask(task);
                    } else {
                      await taskProvider.addTask(task);
                    }
                    Navigator.pop(context);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Error: ${e.toString()}')),
                    );
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.taskToEdit != null ? 'UPDATE' : 'CONFIRM',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
