import 'package:flutter/material.dart';

import '../../core/constants.dart';
import '../auth/login_screen.dart';
import '../auth/register_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 18, 20, 24),
          children: [
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: const Color(0xFF111827),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.directions_car_filled,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'RentFlow',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight: FontWeight.w900,
                          height: 1,
                        ),
                      ),
                      SizedBox(height: 3),
                      Text(
                        'Premium car rental',
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 22),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                height: 310,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      '$imagesUrl/Luxury.jpg',
                      fit: BoxFit.cover,
                      errorBuilder: (_, error, stackTrace) =>
                          Container(color: colors.primary),
                    ),
                    Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.05),
                            Colors.black.withValues(alpha: 0.38),
                            Colors.black.withValues(alpha: 0.82),
                          ],
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(18),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _HeroBadge(
                                icon: Icons.verified_outlined,
                                label: 'Verified cars',
                              ),
                              const SizedBox(width: 8),
                              _HeroBadge(
                                icon: Icons.speed_outlined,
                                label: 'Quick rental',
                              ),
                            ],
                          ),
                          const Spacer(),
                          const Text(
                            'Drive the car that fits your day.',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 31,
                              fontWeight: FontWeight.w900,
                              height: 1.02,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            'Browse availability, reserve dates, and manage requests in one focused app.',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.86),
                              fontSize: 14,
                              height: 1.42,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _MetricCard(
                    value: '6+',
                    label: 'Cars',
                    icon: Icons.directions_car_outlined,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MetricCard(
                    value: 'Live',
                    label: 'Availability',
                    icon: Icons.event_available_outlined,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            FilledButton.icon(
              icon: const Icon(Icons.login),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                );
              },
              label: const Text('Login'),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              icon: const Icon(Icons.person_add_alt_1),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const RegisterScreen()),
                );
              },
              label: const Text('Create an Account'),
            ),
            const SizedBox(height: 24),
            const Text(
              'Designed for',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 12),
            const _FeatureCard(
              icon: Icons.search_outlined,
              title: 'Customers',
              subtitle:
                  'Find a car, choose dates, and submit a booking request.',
            ),
            const SizedBox(height: 10),
            const _FeatureCard(
              icon: Icons.admin_panel_settings_outlined,
              title: 'Managers',
              subtitle: 'Maintain the fleet and approve reservations quickly.',
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroBadge extends StatelessWidget {
  final IconData icon;
  final String label;

  const _HeroBadge({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;

  const _MetricCard({
    required this.value,
    required this.label,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE5ED)),
      ),
      child: Row(
        children: [
          Icon(icon, color: colors.primary, size: 21),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 16,
                ),
              ),
              Text(
                label,
                style: const TextStyle(color: Color(0xFF64748B), fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _FeatureCard({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE5ED)),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: colors.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: colors.primary, size: 21),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Color(0xFF64748B),
                    height: 1.32,
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
