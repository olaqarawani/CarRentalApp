import 'dart:convert';

import 'package:car_rental_appp/screens/cars_list_screen.dart'
    show CarsListScreen;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

import '../../core/constants.dart';
import '../../core/session_manager.dart';
import '../admin/admin_home.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final emailCtrl = TextEditingController();
  final passwordCtrl = TextEditingController();
  bool loading = false;
  bool hidePassword = true;

  @override
  void dispose() {
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

  Future<void> login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => loading = true);

    try {
      final res = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': emailCtrl.text.trim(),
          'password': passwordCtrl.text,
        }),
      );

      final decoded = json.decode(res.body);
      if (decoded is! Map<String, dynamic>) {
        _showMessage('Unexpected server response');
        return;
      }

      if (!mounted) return;
      if (decoded['success'] != true) {
        _showMessage(decoded['message'] ?? 'Login failed');
        return;
      }

      final rawUser = decoded['user'];
      if (rawUser is! Map<String, dynamic>) {
        _showMessage('Invalid user data from server');
        return;
      }

      final role = (rawUser['role'] ?? '').toString();
      await SessionManager.saveSession(
        rawUser['id'],
        role,
        (rawUser['name'] ?? '').toString(),
        (rawUser['email'] ?? '').toString(),
        (decoded['token'] ?? '').toString(),
        (rawUser['profile_image'] ?? '').toString(),
      );

      if (!mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) =>
              role == 'manager' ? const AdminHome() : const CarsListScreen(),
        ),
        (_) => false,
      );
    } catch (error, stackTrace) {
      debugPrint('Login failed: $error');
      debugPrintStack(stackTrace: stackTrace);
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
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton.filledTonal(
                tooltip: 'Back',
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.arrow_back),
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 54,
                    height: 54,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.lock_person_outlined,
                      color: colors.secondary,
                      size: 30,
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Welcome back',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Access your rentals, bookings, and management tools.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Account Details',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w900),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.email],
                    validator: _validateEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email address',
                      hintText: 'name@example.com',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextFormField(
                    controller: passwordCtrl,
                    obscureText: hidePassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.password],
                    validator: (value) =>
                        (value ?? '').isEmpty ? 'Password is required' : null,
                    onFieldSubmitted: (_) => login(),
                    decoration: InputDecoration(
                      labelText: 'Password',
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
                    onPressed: loading ? null : login,
                    icon: loading
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.login),
                    label: Text(loading ? 'Signing in...' : 'Login'),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: colors.primary.withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: colors.primary.withValues(alpha: 0.14),
                      ),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.info_outline, size: 20),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'Use your registered email and password to continue.',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
