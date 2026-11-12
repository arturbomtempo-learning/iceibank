import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/operation_type.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_button.dart';
import 'package:iceibank/ui/core/widgets/fade_slide_in.dart';
import 'package:iceibank/ui/operations/view_models/operation_view_model.dart';
import 'package:iceibank/utils/currency.dart';

class OperationSuccess extends StatelessWidget {
  const OperationSuccess({
    super.key,
    required this.type,
    required this.receipt,
    required this.onDone,
    required this.onAnother,
  });

  final OperationType type;
  final OperationReceipt receipt;
  final VoidCallback onDone;
  final VoidCallback onAnother;

  @override
  Widget build(BuildContext context) {
    final isDeposit = type == OperationType.deposit;
    final signedAmount = '${isDeposit ? '+' : '−'} ${formatCurrency(receipt.amount)}';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.screen),
      child: Column(
        children: [
          const Spacer(),
          const _AnimatedCheck(),
          const SizedBox(height: AppSpacing.xl),
          FadeSlideIn(
            delay: const Duration(milliseconds: 350),
            child: Column(
              children: [
                Text(
                  type.successTitle,
                  style: AppTypography.title1.copyWith(color: context.resolve(AppColors.text)),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  signedAmount,
                  style: AppTypography.amount(30).copyWith(
                    color: context.resolve(isDeposit ? AppColors.primary : AppColors.text),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xxl),
          FadeSlideIn(
            delay: const Duration(milliseconds: 480),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              decoration: BoxDecoration(
                color: context.resolve(AppColors.surface),
                borderRadius: BorderRadius.circular(AppRadius.card),
              ),
              child: Column(
                children: [
                  _ReceiptRow(label: 'Conta', value: '${receipt.account.id}'),
                  _ReceiptRow(label: 'Agência', value: '${receipt.account.agencyId}'),
                  _ReceiptRow(label: 'Titular', value: receipt.account.holderName),
                  _ReceiptRow(
                    label: 'Novo saldo',
                    value: formatCurrency(receipt.newBalance),
                    isEmphasized: true,
                    isLast: true,
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          AppButton(label: 'Concluir', onPressed: onDone),
          CupertinoButton(
            onPressed: onAnother,
            child: Text(isDeposit ? 'Fazer outro depósito' : 'Fazer outro saque'),
          ),
        ],
      ),
    );
  }
}

class _ReceiptRow extends StatelessWidget {
  const _ReceiptRow({
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

class _AnimatedCheck extends StatefulWidget {
  const _AnimatedCheck();

  @override
  State<_AnimatedCheck> createState() => _AnimatedCheckState();
}

class _AnimatedCheckState extends State<_AnimatedCheck> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 850),
  )..forward();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.resolve(AppColors.primary);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Semantics(
      label: 'Operação concluída',
      child: ScaleTransition(
        scale: CurvedAnimation(
          parent: _controller,
          curve: const Interval(0, 0.45, curve: Curves.easeOutBack),
        ),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.resolve(AppColors.primarySoft),
          ),
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: _CheckPainter(
                progress: reduceMotion
                    ? 1
                    : const Interval(
                        0.35,
                        1,
                        curve: Curves.easeOutCubic,
                      ).transform(_controller.value),
                color: color,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckPainter extends CustomPainter {
  const _CheckPainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.29, size.height * 0.52)
      ..lineTo(size.width * 0.44, size.height * 0.66)
      ..lineTo(size.width * 0.72, size.height * 0.37);

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    for (final metric in path.computeMetrics()) {
      canvas.drawPath(metric.extractPath(0, metric.length * progress), paint);
    }
  }

  @override
  bool shouldRepaint(_CheckPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
