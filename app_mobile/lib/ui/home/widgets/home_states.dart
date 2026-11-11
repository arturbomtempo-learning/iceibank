import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/home/widgets/account_card.dart';

class HomeSkeleton extends StatefulWidget {
  const HomeSkeleton({super.key});

  @override
  State<HomeSkeleton> createState() => _HomeSkeletonState();
}

class _HomeSkeletonState extends State<HomeSkeleton> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
    lowerBound: 0.45,
  )..repeat(reverse: true);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Widget _block({double? width, required double height, double radius = AppRadius.sm}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.resolve(AppColors.fill),
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Carregando suas contas',
      child: FadeTransition(
        opacity: _controller,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _block(width: 110, height: 12),
            const SizedBox(height: AppSpacing.md),
            _block(width: 210, height: 36),
            const SizedBox(height: AppSpacing.xl),
            AspectRatio(
              aspectRatio: AccountCard.aspectRatio,
              child: _block(height: double.infinity, radius: AppRadius.card),
            ),
          ],
        ),
      ),
    );
  }
}

class HomeMessage extends StatelessWidget {
  const HomeMessage({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final label = actionLabel;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.resolve(AppColors.surface),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: context.resolve(AppColors.primarySoft),
            ),
            child: Icon(icon, size: 26, color: context.resolve(AppColors.primary)),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.headline.copyWith(color: context.resolve(AppColors.text)),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            message,
            textAlign: TextAlign.center,
            style: AppTypography.subheadline.copyWith(
              color: context.resolve(AppColors.textSecondary),
            ),
          ),
          if (label != null) ...[
            const SizedBox(height: AppSpacing.xl),
            AppButton(label: label, onPressed: onAction),
          ],
        ],
      ),
    );
  }
}
