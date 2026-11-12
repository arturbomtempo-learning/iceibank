import 'package:flutter/cupertino.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class StepProgress extends StatelessWidget {
  const StepProgress({super.key, required this.labels, required this.current});

  final List<String> labels;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Passo ${current + 1} de ${labels.length}: ${labels[current]}',
      child: ExcludeSemantics(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                for (var index = 0; index < labels.length; index++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 320),
                      curve: Curves.easeOutCubic,
                      height: 4,
                      decoration: BoxDecoration(
                        color: context.resolve(
                          index <= current ? AppColors.primary : AppColors.fill,
                        ),
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                  if (index < labels.length - 1) const SizedBox(width: AppSpacing.xs + 2),
                ],
              ],
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'PASSO ${current + 1} DE ${labels.length} · ${labels[current].toUpperCase()}',
              style: AppTypography.eyebrow.copyWith(
                color: context.resolve(AppColors.textSecondary),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
