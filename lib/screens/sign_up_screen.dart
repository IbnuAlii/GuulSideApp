import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:guul_side/screens/sign_in_screen.dart';
import 'package:guul_side/controllers/auth_controller.dart';
import 'package:guul_side/screens/dashboard_screen.dart';
import 'package:guul_side/services/network_service.dart';

class SignUpScreen extends GetView<AuthController> {
  SignUpScreen({Key? key}) : super(key: key);

  final _formKey = GlobalKey<FormState>();
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _showPassword = false.obs;
  final _showConfirmPassword = false.obs;
  final _isLoading = false.obs;
  final _isConnecting = false.obs;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF40E0D0), Color(0xFF1A1A1A)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: 48),
                    _buildSignUpForm(),
                    const SizedBox(height: 24),
                    _buildSignInLink(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Align(
          alignment: Alignment.topRight,
          child: TextButton(
            onPressed: () {
              // Implement menu functionality
            },
            child: const Text(
              '•••',
              style: TextStyle(color: Colors.white70, fontSize: 24),
            ),
          ),
        ),
        const SizedBox(height: 48),
        const Text(
          'Create Your\nAccount',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildSignUpForm() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            label: 'Full Name',
            controller: _fullNameController,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your full name';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          _buildTextField(
            label: 'Email',
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter your email';
              }
              if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$')
                  .hasMatch(value)) {
                return 'Please enter a valid email';
              }
              return null;
            },
          ),
          const SizedBox(height: 24),
          Obx(() => _buildTextField(
                label: 'Password',
                controller: _passwordController,
                obscureText: !_showPassword.value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a password';
                  }
                  if (value.length < 6) {
                    return 'Password must be at least 6 characters long';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _showPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => _showPassword.toggle(),
                ),
              )),
          const SizedBox(height: 24),
          Obx(() => _buildTextField(
                label: 'Confirm Password',
                controller: _confirmPasswordController,
                obscureText: !_showConfirmPassword.value,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please confirm your password';
                  }
                  if (value != _passwordController.text) {
                    return 'Passwords do not match';
                  }
                  return null;
                },
                suffixIcon: IconButton(
                  icon: Icon(
                    _showConfirmPassword.value
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                  ),
                  onPressed: () => _showConfirmPassword.toggle(),
                ),
              )),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: Obx(() => ElevatedButton(
                  onPressed:
                      (_isLoading.value || _isConnecting.value) ? null : _signUp,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF40E0D0),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: _isConnecting.value
                      ? const Text('Connecting...')
                      : _isLoading.value
                          ? const SizedBox(
                              width: 24,
                              height: 24,
                              child: CircularProgressIndicator(
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'SIGN UP',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                )),
          ),
        ],
      ),
    );
  }

  Widget _buildSignInLink() {
    return Center(
      child: TextButton(
        onPressed: () => Get.to(() => SignInScreen()),
        child: const Text(
          "Already have an account? Sign in",
          style: TextStyle(color: Colors.white70),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF40E0D0),
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[200],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide.none,
            ),
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }

  Future<void> _signUp() async {
    if (_formKey.currentState!.validate()) {
      _isConnecting.value = true;

      try {
        await NetworkService.waitForInternet();
        _isConnecting.value = false;
        _isLoading.value = true;

        await controller.signUp(
          _fullNameController.text.trim(),
          _emailController.text.trim(),
          _passwordController.text,
        );

        Get.offAll(() => DashboardScreen());
      } catch (e) {
        String errorMessage = 'An unexpected error occurred';
        if (e is TimeoutException) {
          errorMessage = 'Connection timed out. Please try again.';
        } else if (e.toString().contains('User already exists')) {
          errorMessage = 'An account with this email already exists';
        }
        Get.snackbar(
          'Error',
          errorMessage,
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        _isConnecting.value = false;
        _isLoading.value = false;
      }
    }
  }
}

