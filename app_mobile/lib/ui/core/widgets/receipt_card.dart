import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class ReceiptCard extends StatelessWidget {
  const ReceiptCard({super.key, required this.rows});

  final List<ReceiptRow> rows;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      decoration: BoxDecoration(
        color: context.resolve(AppColors.surface),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(children: rows),
    );
  }
}

class ReceiptRow extends StatelessWidget {
  const ReceiptRow({
    super.key,
    required this.label,
    required this.value,
    this.isEmphasized = false,
    this.isLast = false,
  });

  final String label;
  final String value;
  final bool isEmphasized;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md + 2),
      decoration: BoxDecoration(
        border: isLast ? null : Border(bottom: BorderSide(color: context.resolve(AppColors.fill))),
      ),
      child: Row(
        children: [
          Text(
            label,
            style: AppTypography.subheadline.copyWith(
              color: context.resolve(AppColors.textSecondary),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: isEmphasized
                  ? AppTypography.amount(17).copyWith(color: context.resolve(AppColors.text))
                  : AppTypography.subheadline.copyWith(
                      color: context.resolve(AppColors.text),
                      fontWeight: FontWeight.w600,
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
