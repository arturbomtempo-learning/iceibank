import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class QuickAmounts extends StatelessWidget {
  const QuickAmounts({
    super.key,
    required this.balance,
    this.includeAll = false,
    required this.enabled,
    required this.onSelected,
  });

  final double balance;
  final bool includeAll;
  final bool enabled;
  final ValueChanged<double> onSelected;

  @override
  Widget build(BuildContext context) {
    final options = <(String, double)>[
      ('R\$ 50', 50),
      ('R\$ 100', 100),
      ('R\$ 200', 200),
      if (includeAll && balance > 0) ('Tudo', balance),
    ];

    return Wrap(
      spacing: AppSpacing.sm,
      alignment: WrapAlignment.center,
      children: [
        for (final (label, value) in options)
          CupertinoButton(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            minimumSize: const Size(0, 34),
            color: context.resolve(AppColors.surface),
            borderRadius: BorderRadius.circular(AppRadius.pill),
            onPressed: enabled ? () => onSelected(value) : null,
            child: Text(
              label,
              style: AppTypography.footnote.copyWith(
                color: context.resolve(AppColors.primary),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }
}
