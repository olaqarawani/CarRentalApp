import 'package:car_rental_appp/core/session_manager.dart';
import 'package:car_rental_appp/screens/auth/home_screen.dart';
import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../../widgets/profile_avatar_button.dart';
import 'admin_profile_screen.dart';
import 'manage_bookings_screen.dart';
import 'manage_cars_screen.dart';

class AdminHome extends StatefulWidget {
  const AdminHome({super.key});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  String adminName = 'Administrator';
  String profileImage = '';

  @override
  void initState() {
    super.initState();
    _loadAdminName();
  }

  Future<void> _loadAdminName() async {
    final session = await SessionManager.getSession();
    if (!mounted) return;
    setState(() {
      adminName = (session['name'] ?? 'Administrator').toString();
      profileImage = (session['profileImage'] ?? '').toString();
    });
  }

  Future<void> _logoutToHome() async {
    await SessionManager.logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (_) => false,
    );
  }

  Future<void> _handleBack() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Logout?'),
        content: const Text('Leaving the dashboard will end your session.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Stay'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout'),
          ),
        ],
      ),
    );

    if (shouldLogout == true) await _logoutToHome();
  }

  Future<void> _openProfile() async {
    Navigator.pop(context);
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AdminProfileScreen()),
    );
    await _loadAdminName();
  }

  void _showAdminMenu() {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: CircleAvatar(
                backgroundImage: profileImage.isNotEmpty
                    ? NetworkImage('$imagesUrl/$profileImage')
                    : null,
                child: profileImage.isEmpty
                    ? Text(
                        adminName.isNotEmpty ? adminName[0].toUpperCase() : 'A',
                        style: const TextStyle(fontWeight: FontWeight.w900),
                      )
                    : null,
              ),
              title: Text(adminName),
              subtitle: const Text('Manager account'),
              onTap: _openProfile,
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout', style: TextStyle(color: Colors.red)),
              onTap: _logoutToHome,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) _handleBack();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Dashboard'),
          actions: [
            ProfileAvatarButton(
              imageName: profileImage,
              name: adminName,
              onPressed: _showAdminMenu,
            ),
            IconButton(
              tooltip: 'Account',
              icon: const Icon(Icons.more_vert),
              onPressed: _showAdminMenu,
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Welcome back, $adminName',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Manage the fleet and review customer reservations.',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.82),
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Management Tools',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 14),
            _DashboardTile(
              icon: Icons.directions_car_filled_outlined,
              title: 'Cars Management',
              description: 'Add, edit, or remove cars from the catalog.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const ManageCarsScreen()),
                );
              },
            ),
            const SizedBox(height: 12),
            _DashboardTile(
              icon: Icons.event_note_outlined,
              title: 'Booking Management',
              description: 'Approve, reject, and track booking requests.',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const ManageBookingsScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _DashboardTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final VoidCallback onTap;

  const _DashboardTile({
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: const Color(0xFFE2E8F0)),
          ),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: colors.primary.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: colors.primary),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: const TextStyle(
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}
