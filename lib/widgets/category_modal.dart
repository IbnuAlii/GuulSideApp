import 'package:flutter/material.dart';
import '../models/category.dart';
import '../theme/app_theme.dart';

class CategorySelector extends StatelessWidget {
  final Category? selectedCategory;
  final Function(Category) onCategorySelected;

  const CategorySelector({
    Key? key,
    this.selectedCategory,
    required this.onCategorySelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final categories = [
      Category(name: 'Quit a bad', icon: 'Ban', color: const Color(0xFFe74c3c)),
      Category(name: 'Art', icon: 'PenTool', color: const Color(0xFFe91e63)),
      Category(name: 'Task', icon: 'Clock', color: const Color(0xFFcd849d)),
      Category(name: 'Meditation', icon: 'UserCircle', color: const Color(0xFF9b59b6)),
      Category(name: 'Study', icon: 'GraduationCap', color: const Color(0xFF9b59b6)),
      Category(name: 'Sports', icon: 'Bike', color: const Color(0xFF3498db)),
      Category(name: 'Entertainment', icon: 'Ticket', color: const Color(0xFF40E0D0)),
      Category(name: 'Social', icon: 'MessageSquare', color: const Color(0xFF2ecc71)),
      Category(name: 'Finance', icon: 'DollarSign', color: const Color(0xFF27ae60)),
      Category(name: 'Health', icon: 'Stethoscope', color: const Color(0xFF95a5a6)),
      Category(name: 'Work', icon: 'Briefcase', color: const Color(0xFF95a5a6)),
      Category(name: 'Food', icon: 'Utensils', color: const Color(0xFFf39c12)),
    ];

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
            'Select a category',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 24),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1,
            ),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              final isSelected = category == selectedCategory;
              return InkWell(
                onTap: () => onCategorySelected(category),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: category.color.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: isSelected
                        ? Border.all(color: category.color, width: 2)
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Icon(
                          category.iconData,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        category.name,
                        style: TextStyle(
                          color: category.color,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'CLOSE',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              TextButton(
                onPressed: () {
                  // TODO: Implement manage categories
                },
                child: const Text(
                  'MANAGE CATEGORIES',
                  style: TextStyle(
                    color: AppTheme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

