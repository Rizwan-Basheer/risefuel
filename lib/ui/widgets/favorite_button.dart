import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

class FavoriteButton extends StatelessWidget {
  const FavoriteButton({
    super.key,
    required this.isFavorite,
    required this.onPressed,
  });

  final bool isFavorite;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final icon = isFavorite ? Icons.favorite : Icons.favorite_border;
    final color = isFavorite
        ? AppColors.favorite
        : Theme.of(context).colorScheme.onSurfaceVariant;

    return IconButton(
      tooltip: isFavorite ? 'Remove from favorites' : 'Save to favorites',
      onPressed: onPressed,
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 180),
        transitionBuilder: (child, animation) =>
            ScaleTransition(scale: animation, child: child),
        child: Icon(
          icon,
          key: ValueKey<bool>(isFavorite),
          color: color,
        ),
      ),
    );
  }
}

