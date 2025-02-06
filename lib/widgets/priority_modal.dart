import 'package:flutter/material.dart';
import '../models/task.dart';

class PrioritySelector extends StatelessWidget {
  final Priority selectedPriority;
  final Function(Priority) onPriorityChanged;

  const PrioritySelector({
    Key? key,
    required this.selectedPriority,
    required this.onPriorityChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Set a priority',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                onPressed: () {
                  if (selectedPriority.value > 1) {
                    onPriorityChanged(Priority(
                      value: selectedPriority.value - 1,
                      isDefault: false,
                    ));
                  }
                },
                icon: const Icon(Icons.remove),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.all(12),
                ),
              ),
              const SizedBox(width: 24),
              Text(
                selectedPriority.value.toString(),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 24),
              IconButton(
                onPressed: () {
                  if (selectedPriority.value < 3) {
                    onPriorityChanged(Priority(
                      value: selectedPriority.value + 1,
                      isDefault: false,
                    ));
                  }
                },
                icon: const Icon(Icons.add),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Text(
              'Default',
              style: TextStyle(
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Higher priority activities will be displayed higher in the list',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('CLOSE'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
