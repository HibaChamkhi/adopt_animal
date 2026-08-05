import 'package:flutter/material.dart';
import '../app_theme.dart';

/// Diagonal-striped image placeholder used across the app until real photos load.
class StripedPlaceholder extends StatelessWidget {
  final String label;
  final double borderRadius;
  final double? height;

  const StripedPlaceholder({
    super.key,
    this.label = "photo",
    this.borderRadius = 16,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        color: AppColors.placeholder,
        child: CustomPaint(
          painter: _StripePainter(),
          child: Center(
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.placeholderLabel,
                fontSize: 13,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _StripePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.placeholderStripe
      ..strokeWidth = 7;
    const gap = 20.0;
    for (double x = -size.height; x < size.width; x += gap) {
      canvas.drawLine(
        Offset(x, size.height),
        Offset(x + size.height, 0),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Rounded white search field with a leading search icon.
class AppSearchField extends StatelessWidget {
  final String hint;
  final TextEditingController? controller;
  final ValueChanged<String>? onChanged;
  final VoidCallback? onClear;
  final bool showClear;

  const AppSearchField({
    super.key,
    this.hint = "Search...",
    this.controller,
    this.onChanged,
    this.onClear,
    this.showClear = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(color: Color(0x0F1F2A44), blurRadius: 12, offset: Offset(0, 4)),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        style: AppText.body,
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: AppText.secondary,
          prefixIcon: const Icon(Icons.search, color: AppColors.textSecondary),
          suffixIcon: showClear
              ? IconButton(
                  icon: const Icon(Icons.close, color: AppColors.textSecondary),
                  onPressed: onClear,
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}

/// Bold section title with an optional trailing action ("See all").
class SectionHeader extends StatelessWidget {
  final String title;
  final String? actionText;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.actionText, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: AppText.title),
        if (actionText != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              actionText!,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 15,
              ),
            ),
          ),
      ],
    );
  }
}

/// Pill chip that toggles between selected (filled) and unselected (white).
class SelectableChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback? onTap;

  const SelectableChip({
    super.key,
    required this.label,
    required this.selected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(24),
          boxShadow: const [
            BoxShadow(color: Color(0x0A1F2A44), blurRadius: 8, offset: Offset(0, 2)),
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : AppColors.primary,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}

/// Full-width primary action button (rounded pill).
class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final IconData? icon;

  const PrimaryButton({super.key, required this.label, this.onTap, this.icon});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[Icon(icon, size: 20), const SizedBox(width: 8)],
            Text(
              label,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
      ),
    );
  }
}

enum BadgeType { success, warning, neutral }

/// Small status pill (Available / Pending / Adopted, etc.).
class StatusBadge extends StatelessWidget {
  final String label;
  final BadgeType type;

  const StatusBadge({super.key, required this.label, this.type = BadgeType.success});

  @override
  Widget build(BuildContext context) {
    late Color bg, fg;
    switch (type) {
      case BadgeType.success:
        bg = AppColors.successBg;
        fg = AppColors.success;
        break;
      case BadgeType.warning:
        bg = AppColors.warningBg;
        fg = AppColors.warning;
        break;
      case BadgeType.neutral:
        bg = AppColors.neutralBg;
        fg = AppColors.textSecondary;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(20)),
      child: Text(
        label,
        style: TextStyle(color: fg, fontWeight: FontWeight.w600, fontSize: 13),
      ),
    );
  }
}

/// White rounded box showing a big value over a small label (age / weight / etc.).
class StatTile extends StatelessWidget {
  final String value;
  final String label;

  const StatTile({super.key, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: 2),
          Text(label, style: AppText.secondary),
        ],
      ),
    );
  }
}

/// Reusable animal card (used on Home and the Adopt grid).
class PetCard extends StatelessWidget {
  final String name;
  final String subtitle;
  final String? city;
  final String placeholderLabel;
  final String? imageUrl;
  final bool isFavorite;
  final VoidCallback? onFavorite;
  final VoidCallback? onTap;

  const PetCard({
    super.key,
    required this.name,
    required this.subtitle,
    this.city,
    this.placeholderLabel = "photo",
    this.imageUrl,
    this.isFavorite = false,
    this.onFavorite,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(color: Color(0x0F1F2A44), blurRadius: 14, offset: Offset(0, 6)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                AspectRatio(
                  aspectRatio: 1.15,
                  child: (imageUrl != null && imageUrl!.isNotEmpty)
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(14),
                          child: Image.network(
                            imageUrl!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                            errorBuilder: (_, __, ___) =>
                                StripedPlaceholder(label: placeholderLabel, borderRadius: 14),
                          ),
                        )
                      : StripedPlaceholder(label: placeholderLabel, borderRadius: 14),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onFavorite,
                    child: Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: isFavorite ? AppColors.primary : Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isFavorite ? Icons.favorite : Icons.favorite_border,
                        size: 18,
                        color: isFavorite ? Colors.white : AppColors.primary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              name,
              style: const TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            Text(subtitle, style: AppText.secondary),
            if (city != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 15, color: AppColors.primary),
                  const SizedBox(width: 3),
                  Text(
                    city!,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Centered loading spinner in the app's primary color.
class LoadingView extends StatelessWidget {
  const LoadingView({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(color: AppColors.primary),
    );
  }
}

/// Friendly empty state with an icon, message and optional action.
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;

  const EmptyState({
    super.key,
    this.icon = Icons.pets,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(title, textAlign: TextAlign.center, style: AppText.title),
            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(subtitle!, textAlign: TextAlign.center, style: AppText.secondary),
            ],
            if (actionLabel != null) ...[
              const SizedBox(height: 20),
              SizedBox(width: 200, child: PrimaryButton(label: actionLabel!, onTap: onAction)),
            ],
          ],
        ),
      ),
    );
  }
}

/// Error state with a retry button.
class ErrorRetry extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const ErrorRetry({super.key, this.message = "Something went wrong.", this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, size: 56, color: AppColors.textSecondary),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: AppText.secondary),
            if (onRetry != null) ...[
              const SizedBox(height: 20),
              SizedBox(width: 160, child: PrimaryButton(label: "Retry", onTap: onRetry)),
            ],
          ],
        ),
      ),
    );
  }
}
