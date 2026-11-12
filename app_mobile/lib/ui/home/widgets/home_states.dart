import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
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
