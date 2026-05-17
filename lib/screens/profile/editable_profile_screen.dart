import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

import '../../core/constants.dart';
import '../../core/session_manager.dart';
import '../auth/home_screen.dart';

class EditableProfileScreen extends StatefulWidget {
  final String roleLabel;
  final String accessLabel;
  final IconData fallbackIcon;

  const EditableProfileScreen({
    super.key,
    required this.roleLabel,
    required this.accessLabel,
    required this.fallbackIcon,
  });

  @override
  State<EditableProfileScreen> createState() => _EditableProfileScreenState();
}

class _EditableProfileScreenState extends State<EditableProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();

  int? userId;
  String token = '';
  String profileImage = '';
  File? imageFile;
  bool loading = true;
  bool saving = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadProfile() async {
    final session = await SessionManager.getSession();
    if (!mounted) return;

    setState(() {
      userId = session['userId'] as int?;
      nameCtrl.text = (session['name'] ?? '').toString();
      emailCtrl.text = (session['email'] ?? '').toString();
      token = (session['token'] ?? '').toString();
      profileImage = (session['profileImage'] ?? '').toString();
      loading = false;
    });
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (email.isEmpty) return 'Email is required';
    if (!valid) return 'Enter a valid email address';
    return null;
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 82,
      maxWidth: 900,
    );
    if (picked == null) return;
    setState(() => imageFile = File(picked.path));
  }

  Future<String?> _uploadImage(File image) async {
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('$baseUrl/upload-image'),
    );
    request.files.add(await http.MultipartFile.fromPath('image', image.path));

    final response = await request.send();
    final body = await response.stream.bytesToString();
    final decoded = json.decode(body) as Map<String, dynamic>;

    return decoded['filename']?.toString();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    if (userId == null) {
      _showMessage('Please login again');
      return;
    }

    setState(() => saving = true);

    try {
      var imageName = profileImage;
      if (imageFile != null) {
        imageName = await _uploadImage(imageFile!) ?? '';
      }

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'profile_image': imageName,
        }),
      );

      final decoded = json.decode(response.body) as Map<String, dynamic>;
      if (!mounted) return;

      if (decoded['success'] != true) {
        _showMessage(decoded['message'] ?? 'Profile update failed');
        return;
      }

      final user = decoded['user'] as Map<String, dynamic>;
      await SessionManager.updateProfile(
        name: (user['name'] ?? '').toString(),
        email: (user['email'] ?? '').toString(),
        token: (decoded['token'] ?? token).toString(),
        profileImage: (user['profile_image'] ?? '').toString(),
      );

      if (!mounted) return;
      setState(() {
        profileImage = (user['profile_image'] ?? '').toString();
        imageFile = null;
      });
      _showMessage('Profile updated');
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not update profile');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  Future<void> _logout() async {
    await SessionManager.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  ImageProvider? get _avatarImage {
    if (imageFile != null) {
      return FileImage(imageFile!);
    }
    if (profileImage.isNotEmpty) {
      return NetworkImage('$imagesUrl/$profileImage');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: colors.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Stack(
                        children: [
                          CircleAvatar(
                            radius: 42,
                            backgroundColor: Colors.white.withValues(
                              alpha: 0.18,
                            ),
                            backgroundImage: _avatarImage,
                            child: _avatarImage == null
                                ? Icon(
                                    widget.fallbackIcon,
                                    color: Colors.white,
                                    size: 38,
                                  )
                                : null,
                          ),
                          Positioned(
                            right: 0,
                            bottom: 0,
                            child: InkWell(
                              onTap: _pickImage,
                              borderRadius: BorderRadius.circular(999),
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: colors.secondary,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 17,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              nameCtrl.text.isEmpty
                                  ? 'Your profile'
                                  : nameCtrl.text,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              emailCtrl.text,
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.78),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.14),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                widget.roleLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Personal Information',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: nameCtrl,
                        textInputAction: TextInputAction.next,
                        validator: (value) {
                          final name = value?.trim() ?? '';
                          if (name.isEmpty) return 'Name is required';
                          if (name.length < 3) return 'Name is too short';
                          return null;
                        },
                        decoration: const InputDecoration(
                          labelText: 'Full name',
                          prefixIcon: Icon(Icons.person_outline),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.done,
                        validator: _validateEmail,
                        decoration: const InputDecoration(
                          labelText: 'Email address',
                          prefixIcon: Icon(Icons.email_outlined),
                        ),
                        onChanged: (_) => setState(() {}),
                      ),
                      const SizedBox(height: 14),
                      _InfoTile(
                        icon: Icons.verified_user_outlined,
                        title: 'Access',
                        value: widget.accessLabel,
                      ),
                      const SizedBox(height: 22),
                      FilledButton.icon(
                        onPressed: saving ? null : _saveProfile,
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(saving ? 'Saving...' : 'Save Changes'),
                      ),
                      const SizedBox(height: 12),
                      OutlinedButton.icon(
                        onPressed: _logout,
                        icon: const Icon(Icons.logout),
                        label: const Text('Logout'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                          side: const BorderSide(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;

  const _InfoTile({
    required this.icon,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFE2E8F0)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          Text('$title: ', style: const TextStyle(fontWeight: FontWeight.w900)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Color(0xFF64748B)),
            ),
          ),
        ],
      ),
    );
  }
}
