import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:guul_side/controllers/task_controller.dart';
import 'package:guul_side/controllers/auth_controller.dart';
import 'package:guul_side/models/user.dart';
import 'package:guul_side/services/user_service.dart';
import 'package:guul_side/theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  ProfileScreenState createState() => ProfileScreenState();
}

class ProfileScreenState extends State<ProfileScreen> {
  final UserService _userService = UserService(Get.find<AuthController>());
  late Future<User> _userFuture;
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;

  File? _image;
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _userFuture = _userService.getUserProfile();
    _nameController = TextEditingController();
    _emailController = TextEditingController();
    _phoneController = TextEditingController();
    _locationController = TextEditingController();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _showImageOptions() async {
    Get.bottomSheet(
      SafeArea(
        child: Wrap(
          children: <Widget>[
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('View Image'),
              onTap: () {
                Get.back();
                _viewImage();
              },
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Upload Image'),
              onTap: () {
                Get.back();
                _uploadImage();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _viewImage() async {
    try {
      String imageUrl = await _userService.getProfileImageUrl();
      Get.dialog(
        Dialog(
          child: Container(
            width: 300,
            height: 300,
            decoration: BoxDecoration(
              image: DecorationImage(
                fit: BoxFit.cover,
                image: NetworkImage(imageUrl),
              ),
            ),
          ),
        ),
      );
    } catch (e) {
      Get.snackbar('Error', 'Failed to load image: $e');
    }
  }

  Future<void> _uploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });

      try {
        String imageUrl = await _userService.uploadProfileImage(_image!);
        setState(() {
          _userFuture = _userFuture.then((user) {
            return user.copyWith(imageUrl: imageUrl);
          });
        });
        Get.snackbar('Success', 'Image uploaded successfully');
      } catch (e) {
        Get.snackbar('Error', 'Failed to upload image: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: AppTheme.primaryColor,
      ),
      body: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            User user = snapshot.data!;
            _nameController.text = user.name;
            _emailController.text = user.email;
            _phoneController.text = user.phone ?? '';
            _locationController.text = user.location ?? 'Mogadishu, Somalia';

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _buildProfileHeader(user),
                    const SizedBox(height: 24),
                    _buildStatsGrid(),
                    const SizedBox(height: 24),
                    _buildProfileForm(),
                    const SizedBox(height: 24),
                    _buildSignOutButton(),
                  ],
                ),
              ),
            );
          } else {
            return const Center(child: Text('No user data available'));
          }
        },
      ),
    );
  }

  Widget _buildProfileHeader(User user) {
    return Column(
      children: [
        GestureDetector(
          onTap: _showImageOptions,
          child: Stack(
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[200],
                backgroundImage:
                    user.imageUrl != null ? NetworkImage(user.imageUrl!) : null,
                child: user.imageUrl == null
                    ? const Icon(Icons.person, size: 60, color: Colors.grey)
                    : null,
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          user.name,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildStatsGrid() {
    return GetBuilder<TaskController>(
      builder: (taskController) {
        final tasks = taskController.tasks;
        final completedTasks = tasks.where((task) => task.completed).length;
        final totalTime =
            tasks.fold<int>(0, (sum, task) => sum + (task.completed ? 1 : 0)) *
                15;
        const streakDays = 7; // Implement streak calculation

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 6,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Tasks Done', completedTasks.toString()),
              _buildStatItem(
                  'Total Time', '${totalTime ~/ 60}h ${totalTime % 60}m'),
              _buildStatItem('Day Streak', streakDays.toString()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryColor,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          _buildTextField(_phoneController, 'Phone', Icons.phone),
          _buildTextField(_locationController, 'Location', Icons.location_on),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: _updateProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: const Text('Update Profile'),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(
      TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppTheme.primaryColor),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter $label';
          }
          return null;
        },
      ),
    );
  }

  Widget _buildSignOutButton() {
    return TextButton(
      onPressed: () async {
        try {
          await Get.find<AuthController>().signOut();
          Get.offAllNamed('/');
        } catch (e) {
          Get.snackbar('Error', 'Failed to sign out: $e');
        }
      },
      style: TextButton.styleFrom(
        foregroundColor: Colors.red,
      ),
      child: const Text('Sign Out'),
    );
  }

  void _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        User updatedUser = User(
          id: '', // This should be set by the backend
          name: _nameController.text,
          email: _emailController.text,
          phone: _phoneController.text.isEmpty ? null : _phoneController.text,
          location: _locationController.text.isEmpty
              ? null
              : _locationController.text,
        );

        User result = await _userService.updateUserProfile(updatedUser);
        setState(() {
          _userFuture = Future.value(result);
        });

        Get.snackbar('Success', 'Profile updated successfully');
      } catch (e) {
        Get.snackbar('Error', 'Failed to update profile: $e');
      }
    }
  }
}
