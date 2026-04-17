import 'package:dt_mobile/models/response/profile_response.dart';
import 'package:dt_mobile/services/profile_services.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'dart:io';

class ProfileCardScreen extends StatefulWidget {
  const ProfileCardScreen({super.key});

  @override
  State<ProfileCardScreen> createState() => _ProfileCardScreenState();
}

class _ProfileCardScreenState extends State<ProfileCardScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _currentPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  File? _profileImage;
  ProfileModel? _profile;
  bool _isLoading = true;
  bool _isSaving = false;
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _fetchProfile() async {
    final profile = await ProfileApiService.getProfile();
    if (mounted) {
      setState(() {
        _profile = profile;
        _nameController.text = profile?.name ?? '';
        _emailController.text = profile?.email ?? '';
        _isLoading = false;
      });
    }
  }

  Future<void> _updateProfile() async {
    if (_newPasswordController.text.isNotEmpty) {
      if (_newPasswordController.text != _confirmPasswordController.text) {
        _showSnackbar("New password and confirm password do not match", Colors.red);
        return;
      }
      if (_newPasswordController.text.length < 6) {
        _showSnackbar("New password must be at least 6 characters long", Colors.red);
        return;
      }
      if (_currentPasswordController.text.isEmpty) {
        _showSnackbar("Please enter your current password", Colors.red);
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final result = await ProfileApiService.updateProfile(
        password: _newPasswordController.text.isNotEmpty
            ? _newPasswordController.text
            : null,
        imageFile: _profileImage,
      );

      if (result['success'] == true) {
        _showSnackbar("Profile updated successfully!", Colors.green);

        _currentPasswordController.clear();
        _newPasswordController.clear();
        _confirmPasswordController.clear();

        _profileImage = null;

        await _fetchProfile();

        if (mounted) Navigator.pop(context);

      } else {
        _showSnackbar(result['message'] ?? "Update failed", Colors.red);
      }

    } catch (e) {
      _showSnackbar("An error occurred: $e", Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }




  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 50,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);
        final fileSize = await file.length();
        print("📸 Selected image size: ${(fileSize / 1024).toStringAsFixed(2)} KB");

        if (fileSize > 5 * 1024 * 1024) {
          _showSnackbar("Image too large. Please select image less than 5MB", Colors.red);
          return;
        }

        setState(() => _profileImage = file);
        _showSnackbar("Image selected successfully", Colors.green);
      }
    } catch (e) {
      print('Error picking image: $e');
      _showSnackbar("Failed to pick image: $e", Colors.red);
    }
  }

  void _removeImage() {
    setState(() => _profileImage = null);
  }


  ImageProvider? _getProfileImage() {
    if (_profileImage != null) {
      return FileImage(_profileImage!);
    }

    if (_profile?.image?.url != null && _profile!.image!.url.isNotEmpty) {
      return NetworkImage(_profile!.image!.url);
    }

    return null;
  }

  String _getInitialLetter() {
    if (_profile?.name.isNotEmpty == true) {
      return _profile!.name[0].toUpperCase();
    }
    if (_profile?.email.isNotEmpty == true) {
      return _profile!.email[0].toUpperCase();
    }
    return 'U';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Colors.green),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Card(
              color: Colors.white,
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Personal Info",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "You can view your personal information settings here.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // const Text(
                    //   "Full Name",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 6),
                    _textField(
                      icon: Icons.person_outline,
                      label: "Full Name",
                      controller: _nameController,
                      readOnly: true,
                    ),
                    const SizedBox(height: 16),
                    // const Text(
                    //   "Email Address",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    // const SizedBox(height: 6),
                    _textField(
                      icon: Icons.email_outlined,
                      label: "Email Address",
                      controller: _emailController,
                      readOnly: true,
                    ),
                    const Divider(height: 32),

                    const Text(
                      "Change Password",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "You can change your current password here.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    // const Text(
                    //   "Current Password",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    _passwordField(
                      "Current Password",
                      _currentPasswordController,
                    ),
                    const SizedBox(height: 15),
                    // const Text(
                    //   "New Password",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    _passwordField(
                      "New Password",
                      _newPasswordController,
                    ),
                    const SizedBox(height: 15),
                    // const Text(
                    //   "Confirm New Password",
                    //   style: TextStyle(
                    //     fontSize: 16,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    _passwordField(
                      "Confirm New Password",
                      _confirmPasswordController,
                    ),
                    const Divider(height: 32),

                    const Text(
                      "Profile Picture",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "The picture here can be viewed by other people.",
                      style: TextStyle(color: Colors.grey),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 45,
                          backgroundColor: Colors.green.shade100,
                          backgroundImage: _getProfileImage(),
                          child: (_profileImage == null &&
                              (_profile?.image?.url == null || _profile!.image!.url.isEmpty))
                              ? Text(
                            _getInitialLetter(),
                            style: const TextStyle(
                              color: Colors.green,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                              : null,
                        ),
                        const SizedBox(width: 10),
                        OutlinedButton.icon(
                          onPressed: _pickImage,
                          label: const Text("Update"),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                            foregroundColor: Colors.green,
                            side: const BorderSide(color: Colors.green),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        TextButton.icon(
                          onPressed: _removeImage,
                          icon: const Icon(Icons.delete_outline, size: 14),
                          label: const Text("Remove"),
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    const Divider(),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      side: BorderSide(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Cancel',
                      style: TextStyle(fontSize: 18, color: Colors.black),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _updateProfile,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      minimumSize: const Size.fromHeight(44),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  static Widget _textField({
    required IconData icon,
    required String label,
    required TextEditingController controller,
    bool readOnly = false,
  }) {
    return TextField(
      controller: controller,
      enableInteractiveSelection: false,
      readOnly: readOnly,
      cursorColor: Colors.green,
      decoration: InputDecoration(
        floatingLabelStyle: const TextStyle(color: Colors.green),
        prefixIcon: Icon(icon),
        labelText: label,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.green),
        )
      ),
    );
  }

  /// ── Password Field ────────────────────────────────────────────
  static Widget _passwordField(
      String label,
      TextEditingController controller,
      ) {
    return TextField(
      controller: controller,
      enableInteractiveSelection: false,
      obscureText: true,
      cursorColor: Colors.green,
      decoration: InputDecoration(
        labelText: label,
          floatingLabelStyle: const TextStyle(color: Colors.green),
          border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(25),
          borderSide: const BorderSide(color: Colors.green),
        )
      ),
    );
  }
}