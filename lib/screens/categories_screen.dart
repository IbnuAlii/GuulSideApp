import 'package:flutter/material.dart';
import 'package:guul_side/screens/analytics_screen.dart';
import 'package:guul_side/screens/tasks_screen.dart';
import 'package:guul_side/screens/new_task_screen.dart';
import 'package:provider/provider.dart';
import 'package:guul_side/theme/app_theme.dart';
import 'package:guul_side/services/category_service.dart';
import 'package:guul_side/models/category.dart';

class CategoriesScreen extends StatefulWidget {
  const CategoriesScreen({Key? key}) : super(key: key);

  @override
  _CategoriesScreenState createState() => _CategoriesScreenState();
}

class _CategoriesScreenState extends State<CategoriesScreen>
    with TickerProviderStateMixin {
  List<Category> customCategories = [];
  final TextEditingController _categoryNameController = TextEditingController();
  String _selectedIcon = 'star';
  Color _selectedColor = const Color(0xFF40E0D0);
  bool isModalOpen = false;
  final FocusNode _focusNode = FocusNode();
  late AnimationController _animationController;
  late Animation<double> _animation;
  final CategoryService _categoryService = CategoryService();

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
    _loadCustomCategories();
  }

  void _loadCustomCategories() async {
    final categories = await _categoryService.getCategories();
    setState(() {
      customCategories = categories;
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _animationController.dispose();
    _categoryNameController.dispose();
    super.dispose();
  }

  final defaultCategories = [
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

  void _showAddCategoryModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Add New Category',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _categoryNameController,
                decoration: const InputDecoration(
                  labelText: 'Category Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Icon',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showIconPicker(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Category.getIconData(_selectedIcon)),
                                const SizedBox(width: 8),
                                const Text('Select Icon'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Color',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 8),
                        InkWell(
                          onTap: () => _showColorPicker(),
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.grey),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    color: _selectedColor,
                                    shape: BoxShape.circle,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text('Pick Color'),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close'),
                  ),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: _saveCategory,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                    ),
                    child: const Text('Save'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showIconPicker() {
    final List<String> icons = [
      'Home', 'Work', 'School', 'Sports', 'Favorite',
      'ShoppingCart', 'Restaurant', 'LocalHospital', 'DirectionsBike', 'Movie',
      'MusicNote', 'Book', 'Brush', 'Camera', 'Computer',
      'Pets', 'Flight', 'FitnessCenter', 'Spa', 'ShoppingBag',
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Icon'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: icons.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                setState(() => _selectedIcon = icons[index]);
                Navigator.pop(context);
              },
              child: Icon(Category.getIconData(icons[index]), size: 32),
            ),
          ),
        ),
      ),
    );
  }

  void _showColorPicker() {
    final List<Color> colors = [
      const Color(0xFF40E0D0),
      const Color(0xFFe74c3c),
      const Color(0xFFe91e63),
      const Color(0xFF9b59b6),
      const Color(0xFF3498db),
      const Color(0xFF2ecc71),
      const Color(0xFF27ae60),
      const Color(0xFFf39c12),
      const Color(0xFFd35400),
      const Color(0xFF8e44ad),
    ];

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Color'),
        content: SizedBox(
          width: double.maxFinite,
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 5,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            itemCount: colors.length,
            itemBuilder: (context, index) => InkWell(
              onTap: () {
                setState(() => _selectedColor = colors[index]);
                Navigator.pop(context);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: colors[index],
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _saveCategory() async {
    if (_categoryNameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a category name')),
      );
      return;
    }

    final newCategory = Category(
      name: _categoryNameController.text,
      icon: _selectedIcon,
      color: _selectedColor,
    );

    final savedCategory = await _categoryService.addCategory(newCategory);

    setState(() {
      customCategories.add(savedCategory);
    });

    // Reset form
    _categoryNameController.clear();
    _selectedIcon = 'star';
    _selectedColor = const Color(0xFF40E0D0);

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        backgroundColor: AppTheme.backgroundColor,
        appBar: AppBar(
          title: const Text('Categories',
              style:
                  TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          backgroundColor: AppTheme.primaryColor,
          elevation: 0,
          centerTitle: true,
        ),
        body: FadeTransition(
          opacity: _animation,
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCustomCategories(),
                _buildDefaultCategories(),
              ],
            ),
          ),
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddCategoryModal,
          backgroundColor: AppTheme.primaryColor,
          child: const Icon(Icons.add),
          elevation: 4,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        bottomNavigationBar: _buildBottomNavigationBar(),
      ),
    );
  }

  Widget _buildCustomCategories() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Custom Categories',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor),
          ),
          const SizedBox(height: 8),
          Text(
            '${customCategories.length} available',
            style: TextStyle(color: AppTheme.subtitleColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          if (customCategories.isEmpty)
            _buildEmptyState()
          else
            SizedBox(
              height: 120,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: customCategories.length,
                itemBuilder: (context, index) =>
                    _buildCategoryItem(customCategories[index]),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDefaultCategories() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Default Categories',
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.textColor),
          ),
          const SizedBox(height: 8),
          const Text(
            'Editable for premium users',
            style: TextStyle(color: AppTheme.subtitleColor, fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: defaultCategories.length,
              itemBuilder: (context, index) =>
                  _buildCategoryItem(defaultCategories[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.category, size: 64, color: AppTheme.subtitleColor),
          const SizedBox(height: 16),
          Text(
            'No custom categories yet',
            style: TextStyle(color: AppTheme.subtitleColor, fontSize: 18),
          ),
          const SizedBox(height: 8),
          ElevatedButton(
            onPressed: _showAddCategoryModal,
            child: const Text('Add Category'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(Category category) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => NewTaskScreen(initialCategory: category),
          ),
        );
      },
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
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
                size: 32,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              category.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: AppTheme.textColor),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
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
        currentIndex: 2,
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
          if (!mounted) return;
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
    );
  }
}

