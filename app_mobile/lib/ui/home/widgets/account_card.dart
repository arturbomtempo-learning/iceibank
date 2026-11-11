import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/domain/models/account.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_logo.dart';
import 'package:iceibank/utils/currency.dart';

abstract final class _CardPalette {
  static const Color top = Color(0xFF124A3E);
  static const Color middle = Color(0xFF0A382F);
  static const Color bottom = Color(0xFF03251F);
  static const Color teal = Color(0xFF3FB394);
  static const Color label = Color(0xB3FFFFFF);
}

class AccountCard extends StatefulWidget {
  const AccountCard({super.key, required this.account, required this.isBalanceVisible});

  static const double aspectRatio = 1.586;

  final Account account;
  final bool isBalanceVisible;

  @override
  State<AccountCard> createState() => _AccountCardState();
}

class _AccountCardState extends State<AccountCard> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  );
  late final Animation<double> _rotation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeInOutCubic,
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _flip() {
    HapticFeedback.lightImpact();
    if (_controller.status == AnimationStatus.forward ||
        _controller.status == AnimationStatus.completed) {
      _controller.reverse();
    } else {
      _controller.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Cartão da conta ${widget.account.id}',
      hint: 'Toque para virar o cartão',
      child: GestureDetector(
        onTap: _flip,
        child: AspectRatio(
          aspectRatio: AccountCard.aspectRatio,
          child: AnimatedBuilder(
            animation: _rotation,
            builder: (context, _) {
              final angle = _rotation.value * math.pi;
              final showBack = angle > math.pi / 2;

              return Transform(
                alignment: Alignment.center,
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.0012)
                  ..rotateY(angle),
                child: showBack
                    ? Transform(
                        alignment: Alignment.center,
                        transform: Matrix4.rotationY(math.pi),
                        child: _CardBack(
                          account: widget.account,
                          isBalanceVisible: widget.isBalanceVisible,
                        ),
                      )
                    : _CardFront(account: widget.account),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _CardSurface extends StatelessWidget {
  const _CardSurface({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.card),
        boxShadow: const [
          BoxShadow(color: Color(0x33041A14), blurRadius: 24, offset: Offset(0, 14)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppRadius.card),
        child: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [_CardPalette.top, _CardPalette.middle, _CardPalette.bottom],
              stops: [0, 0.52, 1],
            ),
          ),
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.95, -1.1),
                radius: 1.25,
                colors: [Color(0x3357E3A8), Color(0x0057E3A8)],
              ),
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}

class _CardFront extends StatelessWidget {
  const _CardFront({required this.account});

  final Account account;

  @override
  Widget build(BuildContext context) {
    final lastDigits = account.id.toString().padLeft(4, '0');

    return _CardSurface(
      child: Stack(
        children: [
          Positioned(
            right: -28,
            bottom: -36,
            child: CustomPaint(size: const Size.square(170), painter: _MarkWatermarkPainter()),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.xl - 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const AppLogo(variant: AppLogoVariant.onInk, markSize: 24),
                    const Spacer(),
                    CustomPaint(size: const Size(22, 26), painter: _ContactlessPainter()),
                  ],
                ),
                const Spacer(),
                CustomPaint(size: const Size(44, 32), painter: _ChipPainter()),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  '••••  ••••  ••••  $lastDigits',
                  style: AppTypography.amount(17)
                      .copyWith(color: AppColors.white, letterSpacing: 1.6),
                ),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        account.holderName.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTypography.eyebrow.copyWith(color: AppColors.white, fontSize: 12),
                      ),
                    ),
                    const Icon(
                      CupertinoIcons.arrow_2_circlepath,
                      size: 15,
                      color: _CardPalette.label,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardBack extends StatelessWidget {
  const _CardBack({required this.account, required this.isBalanceVisible});

  final Account account;
  final bool isBalanceVisible;

  @override
  Widget build(BuildContext context) {
    final remainder = account.id % AgencyEndpoints.count;

    return _CardSurface(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: AppSpacing.lg),
          Container(height: 34, color: const Color(0xE6010C09)),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.xl - 2,
                AppSpacing.md,
                AppSpacing.xl - 2,
                AppSpacing.lg,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _CardField(label: 'Agência', value: '${account.agencyId}'),
                      ),
                      Expanded(
                        child: _CardField(label: 'Conta', value: '${account.id}'),
                      ),
                      Expanded(
                        flex: 2,
                        child: _CardField(
                          label: 'Saldo',
                          value: isBalanceVisible ? formatCurrency(account.balance) : 'R\$ ••••',
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _CardField(label: 'Usuário', value: '@${account.owner}'),
                  const Spacer(),
                  Text(
                    '${account.id} ÷ ${AgencyEndpoints.count} deixa resto $remainder: '
                    'por isso esta conta vive na Agência ${account.agencyId}.',
                    style: AppTypography.caption.copyWith(color: _CardPalette.label, height: 1.35),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CardField extends StatelessWidget {
  const _CardField({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          label.toUpperCase(),
          style: AppTypography.eyebrow.copyWith(color: _CardPalette.teal, fontSize: 10),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: AppTypography.amount(16).copyWith(color: AppColors.white),
        ),
      ],
    );
  }
}

class _MarkWatermarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas
      ..scale(size.width / 40)
      ..translate(20, 20)
      ..rotate(-math.pi / 4)
      ..translate(-20, -20);

    final paint = Paint()..color = const Color(0x0FFFFFFF);
    const bars = [
      Rect.fromLTWH(8, 9.6, 24, 4.6),
      Rect.fromLTWH(11, 17.7, 18, 4.6),
      Rect.fromLTWH(14, 25.8, 12, 4.6),
    ];
    for (final bar in bars) {
      canvas.drawRRect(RRect.fromRectAndRadius(bar, const Radius.circular(2.3)), paint);
    }
  }

  @override
  bool shouldRepaint(_MarkWatermarkPainter oldDelegate) => false;
}

class _ChipPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 40, size.height / 29);

    const body = Rect.fromLTWH(0, 0, 40, 29);
    final fill = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFFE2E6E5), Color(0xFFA9AFAE)],
      ).createShader(body);
    canvas.drawRRect(RRect.fromRectAndRadius(body, const Radius.circular(5.5)), fill);

    final lines = Paint()
      ..color = const Color(0x730A382F)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4;
    final path = Path()
      ..moveTo(0, 10)
      ..lineTo(12.5, 10)
      ..moveTo(0, 19)
      ..lineTo(12.5, 19)
      ..moveTo(27.5, 10)
      ..lineTo(40, 10)
      ..moveTo(27.5, 19)
      ..lineTo(40, 19)
      ..moveTo(20, 0)
      ..lineTo(20, 6)
      ..moveTo(20, 23)
      ..lineTo(20, 29);
    canvas
      ..drawPath(path, lines)
      ..drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(12.5, 6, 15, 17), const Radius.circular(4)),
        lines,
      );
  }

  @override
  bool shouldRepaint(_ChipPainter oldDelegate) => false;
}

class _ContactlessPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xE0CFE3DB)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final center = Offset(0, size.height / 2);
    for (final radius in [5.0, 10.0, 15.0, 20.0]) {
      canvas.drawArc(Rect.fromCircle(center: center, radius: radius), -0.62, 1.24, false, paint);
    }
  }

  @override
  bool shouldRepaint(_ContactlessPainter oldDelegate) => false;
}
