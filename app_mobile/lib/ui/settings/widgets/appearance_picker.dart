import 'package:flutter/cupertino.dart';
import 'package:iceibank/domain/models/theme_preference.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class AppearancePicker extends StatelessWidget {
  const AppearancePicker({super.key, required this.selected, required this.onSelected});

  final ThemePreference selected;
  final ValueChanged<ThemePreference> onSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final preference in ThemePreference.values) ...[
          Expanded(
            child: _AppearanceOption(
              preference: preference,
              isSelected: preference == selected,
              onTap: () => onSelected(preference),
            ),
          ),
          if (preference != ThemePreference.values.last) const SizedBox(width: AppSpacing.md),
        ],
      ],
    );
  }
}

class _AppearanceOption extends StatelessWidget {
  const _AppearanceOption({
    required this.preference,
    required this.isSelected,
    required this.onTap,
  });

  final ThemePreference preference;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 220);
    final primary = context.resolve(AppColors.primary);

    return Semantics(
      button: true,
      selected: isSelected,
      label: 'Aparência ${preference.label}',
      child: ExcludeSemantics(
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          child: Column(
            children: [
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isSelected ? primary : const Color(0x00000000),
                    width: 2,
                  ),
                ),
                child: AnimatedScale(
                  duration: duration,
                  curve: Curves.easeOutBack,
                  scale: isSelected ? 1 : 0.96,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: AspectRatio(
                      aspectRatio: 0.62,
                      child: switch (preference) {
                        ThemePreference.light => const _MiniApp(isDark: false),
                        ThemePreference.dark => const _MiniApp(isDark: true),
                        ThemePreference.system => const Stack(
                          fit: StackFit.expand,
                          children: [
                            _MiniApp(isDark: false),
                            ClipPath(clipper: _DiagonalClipper(), child: _MiniApp(isDark: true)),
                          ],
                        ),
                      },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                preference.label,
                style: AppTypography.subheadline.copyWith(
                  color: context.resolve(AppColors.text),
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                ),
              ),
              const SizedBox(height: 6),
              AnimatedSwitcher(
                duration: duration,
                transitionBuilder: (child, animation) =>
                    ScaleTransition(scale: animation, child: child),
                child: Icon(
                  isSelected ? CupertinoIcons.checkmark_circle_fill : CupertinoIcons.circle,
                  key: ValueKey(isSelected),
                  size: 22,
                  color: isSelected ? primary : context.resolve(AppColors.textTertiary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MiniApp extends StatelessWidget {
  const _MiniApp({required this.isDark});

  final bool isDark;

  Color _pick(CupertinoDynamicColor color) => isDark ? color.darkColor : color.color;

  @override
  Widget build(BuildContext context) {
    final line = _pick(AppColors.fill);
    final text = _pick(AppColors.text);

    return ColoredBox(
      color: _pick(AppColors.background),
      child: FittedBox(
        fit: BoxFit.cover,
        child: SizedBox(width: 90, height: 145, child: _content(text, line)),
      ),
    );
  }

  Widget _content(Color text, Color line) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: 12,
            child: Row(
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _pick(AppColors.primarySoft),
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(child: _Bar(color: text.withValues(alpha: 0.85), widthFactor: 0.7)),
              ],
            ),
          ),
          const SizedBox(height: 6),
          _Bar(color: text.withValues(alpha: 0.9), widthFactor: 0.55, height: 6),
          const SizedBox(height: 6),
          Container(
            height: 34,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(5),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFF124A3E), Color(0xFF03251F)],
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            height: 20,
            child: Row(
              children: [
                for (var index = 0; index < 3; index++) ...[
                  Expanded(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: _pick(AppColors.surface),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Center(
                        child: Container(
                          width: 5,
                          height: 5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _pick(AppColors.primary),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (index < 2) const SizedBox(width: 5),
                ],
              ],
            ),
          ),
          const SizedBox(height: 6),
          Container(
            height: 22,
            padding: const EdgeInsets.all(5),
            decoration: BoxDecoration(
              color: _pick(AppColors.surface),
              borderRadius: BorderRadius.circular(5),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _Bar(color: line, widthFactor: 0.8, height: 3),
                _Bar(color: line, widthFactor: 0.5, height: 3),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Bar extends StatelessWidget {
  const _Bar({required this.color, required this.widthFactor, this.height = 4});

  final Color color;
  final double widthFactor;
  final double height;

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      alignment: Alignment.centerLeft,
      widthFactor: widthFactor,
      child: Container(
        height: height,
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(height)),
      ),
    );
  }
}

class _DiagonalClipper extends CustomClipper<Path> {
  const _DiagonalClipper();

  @override
  Path getClip(Size size) {
    return Path()
      ..moveTo(size.width, 0)
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();
  }

  @override
  bool shouldReclip(_DiagonalClipper oldClipper) => false;
}
