import 'package:flutter/material.dart';

import '../profile/editable_profile_screen.dart';

class AdminProfileScreen extends StatelessWidget {
  const AdminProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditableProfileScreen(
      roleLabel: 'Manager',
      accessLabel: 'Full system access',
      fallbackIcon: Icons.admin_panel_settings,
    );
  }
}
