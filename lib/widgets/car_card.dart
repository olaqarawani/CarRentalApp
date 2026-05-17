import 'package:flutter/material.dart';

import '../core/constants.dart';
import '../models/car.dart';

class CarCard extends StatelessWidget {
  final Car car;
  final VoidCallback onTap;

  const CarCard({super.key, required this.car, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: const Color(0xFFDDE5ED)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(8),
                ),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      car.image.isEmpty
                          ? Container(color: const Color(0xFFE2E8F0))
                          : Image.network(
                              '$imagesUrl/${car.image}',
                              fit: BoxFit.cover,
                              errorBuilder: (_, error, stackTrace) => Container(
                                color: const Color(0xFFE2E8F0),
                                alignment: Alignment.center,
                                child: const Icon(Icons.image_not_supported),
                              ),
                            ),
                      Positioned(
                        top: 12,
                        left: 12,
                        child: _StatusPill(available: car.available),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(13),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            car.type,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF111827),
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 7,
                          ),
                          decoration: BoxDecoration(
                            color: colors.primary.withValues(alpha: 0.08),
                            borderRadius: BorderRadius.circular(999),
                          ),
                          child: Text(
                            '${car.pricePerDay} ILS',
                            style: TextStyle(
                              color: colors.primary,
                              fontWeight: FontWeight.w900,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      car.description,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF64748B),
                        height: 1.35,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        _Spec(icon: Icons.payments_outlined, label: 'Per day'),
                        const SizedBox(width: 12),
                        _Spec(icon: Icons.event_available, label: 'Flexible'),
                        const Spacer(),
                        Icon(
                          Icons.arrow_forward,
                          color: colors.primary,
                          size: 20,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final bool available;

  const _StatusPill({required this.available});

  @override
  Widget build(BuildContext context) {
    final bg = available ? const Color(0xFFE8FFF7) : const Color(0xFFFFEDEE);
    final fg = available ? const Color(0xFF047857) : const Color(0xFFB42318);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(999),
      ),
      child: Text(
        available ? 'Available' : 'Unavailable',
        style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w900),
      ),
    );
  }
}

class _Spec extends StatelessWidget {
  final IconData icon;
  final String label;

  const _Spec({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 16, color: const Color(0xFF64748B)),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF64748B),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
