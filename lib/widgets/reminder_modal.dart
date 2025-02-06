import 'package:flutter/material.dart';

class ReminderModal extends StatefulWidget {
  final Map<String, dynamic>? initialReminder;

  const ReminderModal({Key? key, this.initialReminder}) : super(key: key);

  @override
  _ReminderModalState createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  late TimeOfDay _selectedTime;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    if (widget.initialReminder != null) {
      final reminderDateTime = DateTime.parse(widget.initialReminder!['date']);
      _selectedTime = TimeOfDay.fromDateTime(reminderDateTime);
      _selectedDate = reminderDateTime;
    } else {
      _selectedTime = TimeOfDay.now();
      _selectedDate = DateTime.now();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Set Reminder',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: _selectedTime,
                    );
                    if (time != null) {
                      setState(() {
                        _selectedTime = time;
                      });
                    }
                  },
                  child: Text(_selectedTime.format(context)),
                ),
                TextButton(
                  onPressed: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setState(() {
                        _selectedDate = date;
                      });
                    }
                  },
                  child: Text(
                    '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('CANCEL'),
                ),
                ElevatedButton(
                  onPressed: () {
                    final reminderDateTime = DateTime(
                      _selectedDate.year,
                      _selectedDate.month,
                      _selectedDate.day,
                      _selectedTime.hour,
                      _selectedTime.minute,
                    );
                    Navigator.pop(context, {
                      'time': _selectedTime.format(context),
                      'date': reminderDateTime.toIso8601String(),
                    });
                  },
                  child: const Text('SET REMINDER'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
