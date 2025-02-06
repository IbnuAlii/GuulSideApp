import 'package:flutter/material.dart';
import 'package:guul_side/screens/analytics_screen.dart';
import 'package:guul_side/screens/categories_screen.dart';
import 'package:provider/provider.dart';
import 'package:guul_side/controllers/theme_controller.dart';
import 'package:guul_side/controllers/auth_controller.dart';
import 'package:guul_side/screens/profile_screen.dart';
import 'package:guul_side/screens/sign_in_screen.dart';

class SidebarMenu extends StatelessWidget {
  const SidebarMenu({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeController>(context);
    final authProvider = Provider.of<AuthController>(context);

    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  const Color(0xFF40E0D0),
                  themeProvider.themeMode == ThemeMode.dark
                      ? Colors.blue.shade900
                      : Colors.blue.shade600,
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Guul Side',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  DateTime.now().toLocal().toString().split(' ')[0],
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
          ListTile(
            leading: const Icon(Icons.home),
            title: const Text('Home'),
            onTap: () {
              Navigator.pop(context);
              Navigator.pushReplacementNamed(context, '/dashboard');
            },
          ),
          ListTile(
            leading: const Icon(Icons.timer),
            title: const Text('Analytics'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const AnalyticsScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.category),
            title: const Text('Categories'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CategoriesScreen()),
              );
            },
          ),
          ListTile(
            leading: Icon(themeProvider.themeMode == ThemeMode.dark
                ? Icons.light_mode
                : Icons.dark_mode),
            title: Text(themeProvider.themeMode == ThemeMode.dark
                ? 'Light Mode'
                : 'Dark Mode'),
            onTap: () {
              themeProvider.toggleTheme();
            },
          ),
          ListTile(
            leading: const Icon(Icons.person),
            title: const Text('Profile'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const ProfileScreen()),
              );
            },
          ),
          ListTile(
            leading: const Icon(Icons.logout),
            title: const Text('Logout'),
            onTap: () async {
              try {
                await authProvider.signOut();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (context) => SignInScreen()),
                  (Route<dynamic> route) => false,
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Error logging out: $e')),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
