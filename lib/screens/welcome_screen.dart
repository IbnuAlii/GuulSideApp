import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guul_side/screens/sign_in_screen.dart';
import 'package:guul_side/screens/sign_up_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF40E0D0), Color(0xFF3498db)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: Get.height - Get.mediaQuery.padding.top,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    _buildMenuButton(),
                    Expanded(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildLogo(),
                          const SizedBox(height: 24),
                          _buildAppTitle(),
                          const SizedBox(height: 8),
                          _buildAppSubtitle(),
                          const SizedBox(height: 48),
                          _buildWelcomeText(),
                          const SizedBox(height: 24),
                          _buildSignInButton(),
                          const SizedBox(height: 16),
                          _buildSignUpButton(),
                        ],
                      ),
                    ),
                    _buildSocialLoginSection(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton() {
    return Align(
      alignment: Alignment.topRight,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: TextButton(
          onPressed: () {
            Get.dialog(
              AlertDialog(
                title: const Text('Menu'),
                content: const Text('Menu options will be implemented here.'),
                actions: <Widget>[
                  TextButton(
                    child: const Text('Close'),
                    onPressed: () => Get.back(),
                  ),
                ],
              ),
            );
          },
          child: const Text(
            '•••',
            style: TextStyle(color: Colors.white70, fontSize: 24),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 120,
      height: 120,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withAlpha(51), // 0.2 opacity
      ),
      child: Center(
        child: SvgPicture.asset(
          'assets/images/clipboard_check.svg',
          width: 60,
          height: 60,
          colorFilter: const ColorFilter.mode(Colors.white, BlendMode.srcIn),
        ),
      ),
    );
  }

  Widget _buildAppTitle() {
    return const Text(
      'Guul Side',
      style: TextStyle(
        fontFamily: 'DancingScript',
        fontSize: 48,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildAppSubtitle() {
    return const Text(
      'Guusha Maanta, Guusha Berri',
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w500,
        color: Colors.white70,
      ),
    );
  }

  Widget _buildWelcomeText() {
    return const Text(
      'Welcome Back',
      style: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  Widget _buildSignInButton() {
    return SizedBox(
      width: 280,
      child: ElevatedButton(
        onPressed: () => Get.to(() => SignInScreen()),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: const Color(0xFF40E0D0),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'SIGN IN',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: 280,
      child: OutlinedButton(
        onPressed: () => Get.to(() => SignUpScreen()),
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          side: const BorderSide(color: Colors.white70),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: const Text(
          'SIGN UP',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildSocialLoginSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: [
          const Text(
            'Login with Social Media',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _socialButton('assets/images/instagram.svg'),
              const SizedBox(width: 24),
              _socialButton('assets/images/twitter.svg'),
              const SizedBox(width: 24),
              _socialButton('assets/images/facebook.svg'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _socialButton(String assetName) {
    return InkWell(
      onTap: () {
        print('Social media login with $assetName');
      },
      child: SvgPicture.asset(
        assetName,
        width: 28,
        height: 28,
        colorFilter: ColorFilter.mode(Colors.white.withAlpha(230), BlendMode.srcIn),
      ),
    );
  }
}

