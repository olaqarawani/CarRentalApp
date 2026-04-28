import 'package:flutter/material.dart';

class MiniSpecsRow extends StatelessWidget {
  final int seats;
  final int bags;
  final String transmission;

  const MiniSpecsRow({
    super.key,
    required this.seats,
    required this.bags,
    required this.transmission,
  });

  Widget _chip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF2F4FF),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16),
          const SizedBox(width: 6),
          Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        _chip(Icons.people_alt_outlined, '$seats Seats'),
        _chip(Icons.work_outline, '$bags Bags'),
        _chip(Icons.settings, transmission),
      ],
    );
  }
}
