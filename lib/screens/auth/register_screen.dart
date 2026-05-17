import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? value) {
    final email = value?.trim() ?? '';
    final valid = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
    if (email.isEmpty) return 'Email is required';
    if (!valid) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? value) {
    final password = value ?? '';
    if (password.length < 8) return 'Use at least 8 characters';
    if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
        !RegExp(r'\d').hasMatch(password)) {
      return 'Use letters and numbers';
    }
    return null;
  }

  Future<void> register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'name': nameCtrl.text.trim(),
          'email': emailCtrl.text.trim(),
          'password': passwordCtrl.text,
        }),
      );

      final data = json.decode(res.body) as Map<String, dynamic>;

      if (!mounted) return;
      if (data['success'] != true) {
        _showMessage(data['message'] ?? 'Registration failed');
        return;
      }

      _showMessage('Account created. Please login to continue.');
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } catch (_) {
      if (!mounted) return;
      _showMessage('Could not connect to the server');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Create Account')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(
                    Icons.person_add_alt_1_outlined,
                    size: 64,
                    color: colors.primary,
                  ),
                  const SizedBox(height: 18),
                  const Text(
                    'Create your account',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Use a valid email and a secure password to start booking.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.black54),
                  ),
                  const SizedBox(height: 28),
                  TextFormField(
                    controller: nameCtrl,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.name],
                    validator: (value) {
                      final name = value?.trim() ?? '';
                      if (name.isEmpty) return 'Full name is required';
                      if (name.length < 3) return 'Name is too short';
                      return null;
                    },
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: _validateEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    validator: _validatePassword,
                    onFieldSubmitted: (_) => register(),
                    decoration: InputDecoration(
                      labelText: 'Password',
                      helperText:
                          'At least 8 characters with letters and numbers',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        tooltip: hidePassword
                            ? 'Show password'
                            : 'Hide password',
                        onPressed: () {
                          setState(() => hidePassword = !hidePassword);
                        },
                        icon: Icon(
                          hidePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 22),
                  FilledButton.icon(
                    onPressed: loading ? null : register,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.person_add_alt_1),
                    label: Text(loading ? 'Creating account...' : 'Register'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
