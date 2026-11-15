import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class HomeHeader extends StatelessWidget {
  const HomeHeader({
    super.key,
    required this.initials,
    required this.greetingName,
    required this.subtitle,
    required this.onOpenSettings,
  });

  final String initials;
  final String greetingName;
  final String subtitle;
  final VoidCallback onOpenSettings;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Semantics(
          button: true,
          label: 'Abrir perfil e ajustes',
          child: ExcludeSemantics(
            child: GestureDetector(
              onTap: onOpenSettings,
              child: Container(
                width: AppSizes.minTapTarget,
                height: AppSizes.minTapTarget,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: context.resolve(AppColors.primarySoft),
                ),
                child: Text(
                  initials,
                  style: AppTypography.brand(
                    15,
                    weight: FontWeight.w700,
                  ).copyWith(color: context.resolve(AppColors.onPrimarySoft)),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Olá, $greetingName',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppTypography.title2.copyWith(color: context.resolve(AppColors.text)),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.footnote.copyWith(
                  color: context.resolve(AppColors.textSecondary),
                ),
              ),
            ],
          ),
        ),
        Semantics(
          button: true,
          label: 'Ajustes',
          child: ExcludeSemantics(
            child: CupertinoButton(
              padding: EdgeInsets.zero,
              minimumSize: const Size.square(AppSizes.minTapTarget),
              onPressed: onOpenSettings,
              child: Icon(
                CupertinoIcons.gear_alt,
                size: 22,
                color: context.resolve(AppColors.textSecondary),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
