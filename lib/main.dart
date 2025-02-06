import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:flutter/services.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import 'controllers/auth_controller.dart';
import 'controllers/task_controller.dart';
import 'controllers/theme_controller.dart';
import 'screens/dashboard_screen.dart';
import 'screens/welcome_screen.dart';
import 'screens/loading_screen.dart';
import 'screens/error_screen.dart';

void main() async {
  await initApp();
  runApp(const MyApp());
}

Future<void> initApp() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize controllers
  Get.put(AuthController());
  Get.put(TaskController());
  Get.put(ThemeController());

  // Initialize connectivity listener
  final connectivity = Connectivity();
  connectivity.onConnectivityChanged.listen((result) {
    print('Connectivity changed: $result');
    if (result != ConnectivityResult.none) {
      Get.find<AuthController>().checkAuthentication();
    }
  });

  // Perform initial connectivity check
  final connectivityResult = await connectivity.checkConnectivity();
  if (connectivityResult != ConnectivityResult.none) {
    Get.find<AuthController>().checkAuthentication();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Guul Side',
      theme: ThemeData(
        primaryColor: const Color(0xFF40E0D0),
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Inter',
      ),
      darkTheme: ThemeData.dark().copyWith(
        primaryColor: const Color(0xFF40E0D0),
        scaffoldBackgroundColor: const Color(0xFF1A1A1A),
      ),
      themeMode: Get.find<ThemeController>().themeMode,
      home: Obx(() {
        final authController = Get.find<AuthController>();

        if (!authController.isInitialized) {
          return const LoadingScreen();
        }

        if (authController.hasError) {
          return ErrorScreen(
            message: authController.errorMessage,
            onRetry: () => authController.checkAuthentication(),
          );
        }

        return authController.isAuthenticated
            ? DashboardScreen()
            : const WelcomeScreen();
      }),
      getPages: [
        GetPage(name: '/dashboard', page: () => DashboardScreen()),
        GetPage(name: '/welcome', page: () => const WelcomeScreen()),
      ],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('so', ''),
      ],
    );
  }
}
