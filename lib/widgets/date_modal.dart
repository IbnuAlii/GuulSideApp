import 'package:flutter/material.dart';

class DateModal extends StatefulWidget {
  final DateTime initialStartDate;
  final DateTime initialEndDate;

  const DateModal({
    Key? key,
    required this.initialStartDate,
    required this.initialEndDate,
  }) : super(key: key);

  @override
  _DateModalState createState() => _DateModalState();
}

class _DateModalState extends State<DateModal> {
  late DateTime _startDate;
  late DateTime _endDate;

  @override
  void initState() {
    super.initState();
    _startDate = widget.initialStartDate;
    _endDate = widget.initialEndDate;
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
              'Select Date Range',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Start Date'),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _startDate,
                          firstDate: DateTime.now(),
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _startDate = date;
                          });
                        }
                      },
                      child: Text(
                        '${_startDate.day}/${_startDate.month}/${_startDate.year}',
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('End Date'),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: _endDate,
                          firstDate: _startDate,
                          lastDate:
                              DateTime.now().add(const Duration(days: 365)),
                        );
                        if (date != null) {
                          setState(() {
                            _endDate = date;
                          });
                        }
                      },
                      child: Text(
                        '${_endDate.day}/${_endDate.month}/${_endDate.year}',
                      ),
                    ),
                  ],
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
                    Navigator.pop(context, {
                      'startDate': _startDate,
                      'endDate': _endDate,
                    });
                  },
                  child: const Text('OK'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
