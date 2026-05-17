import 'package:flutter/material.dart';

import '../core/constants.dart';

class ProfileAvatarButton extends StatelessWidget {
  final String imageName;
  final String name;
  final VoidCallback onPressed;

  const ProfileAvatarButton({
    super.key,
    required this.imageName,
    required this.name,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    final initial = name.trim().isNotEmpty ? name.trim()[0].toUpperCase() : '?';

    return Padding(
      padding: const EdgeInsetsDirectional.only(end: 8),
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(999),
        child: CircleAvatar(
          radius: 18,
          backgroundColor: colors.primary.withValues(alpha: 0.12),
          backgroundImage: imageName.isNotEmpty
              ? NetworkImage('$imagesUrl/$imageName')
              : null,
          child: imageName.isEmpty
              ? Text(
                  initial,
                  style: TextStyle(
                    color: colors.primary,
                    fontWeight: FontWeight.w900,
                  ),
                )
              : null,
        ),
      ),
    );
  }
}
