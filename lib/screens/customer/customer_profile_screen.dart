import 'package:flutter/material.dart';

import '../profile/editable_profile_screen.dart';

class CustomerProfileScreen extends StatelessWidget {
  const CustomerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const EditableProfileScreen(
      roleLabel: 'Customer',
      accessLabel: 'Bookings & Rentals',
      fallbackIcon: Icons.person,
    );
  }
}
