import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/data/repositories/theme_repository.dart';
import 'package:iceibank/domain/models/theme_preference.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/settings/view_models/settings_view_model.dart';
import 'package:iceibank/ui/settings/widgets/appearance_picker.dart';

class SettingsProfile {
  const SettingsProfile({
    required this.initials,
    required this.name,
    required this.username,
    required this.roleLabel,
  });

  final String initials;
  final String name;
  final String username;
  final String roleLabel;
}

Future<bool?> showSettingsSheet(
  BuildContext context, {
  required ThemeRepository themeRepository,
  required SettingsProfile profile,
}) {
  return showCupertinoSheet<bool>(
    context: context,
    scrollableBuilder: (context, scrollController) => SettingsSheet(
      themeRepository: themeRepository,
      profile: profile,
      scrollController: scrollController,
    ),
  );
}

class SettingsSheet extends StatefulWidget {
  const SettingsSheet({
    super.key,
    required this.themeRepository,
    required this.profile,
    required this.scrollController,
  });

  final ThemeRepository themeRepository;
  final SettingsProfile profile;
  final ScrollController scrollController;

  @override
  State<SettingsSheet> createState() => _SettingsSheetState();
}

class _SettingsSheetState extends State<SettingsSheet> {
  late final SettingsViewModel _viewModel = SettingsViewModel(
    themeRepository: widget.themeRepository,
  );

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  void _selectTheme(ThemePreference preference) {
    if (preference == _viewModel.themePreference) return;
    HapticFeedback.selectionClick();
    _viewModel.selectTheme(preference);
  }

  @override
  Widget build(BuildContext context) {
    final background = context.resolve(AppColors.background);
    final profile = widget.profile;

    return CupertinoPageScaffold(
      backgroundColor: background,
      navigationBar: CupertinoNavigationBar(
        automaticallyImplyLeading: false,
        middle: const Text('Ajustes'),
        trailing: CupertinoButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('OK', style: TextStyle(fontWeight: FontWeight.w600)),
        ),
        backgroundColor: background,
        border: null,
      ),
      child: SafeArea(
        child: ListView(
          controller: widget.scrollController,
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.lg,
            AppSpacing.screen,
            AppSpacing.xxl,
          ),
          children: [
            _ProfileHeader(profile: profile),
            const SizedBox(height: AppSpacing.xxl),
            const _SectionLabel('Aparência'),
            const SizedBox(height: AppSpacing.sm),
            _Card(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.lg,
                  AppSpacing.md,
                ),
                child: ListenableBuilder(
                  listenable: _viewModel,
                  builder: (context, _) => AppearancePicker(
                    selected: _viewModel.themePreference,
                    onSelected: _selectTheme,
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Text(
                'No modo Automático, o app acompanha o tema escolhido nos ajustes do aparelho. '
                'A escolha fica salva só neste app.',
                style: AppTypography.footnote.copyWith(
                  color: context.resolve(AppColors.textSecondary),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.xxl),
            const _SectionLabel('Conta'),
            const SizedBox(height: AppSpacing.sm),
            _Card(
              child: CupertinoListTile(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.md,
                ),
                leading: Icon(
                  CupertinoIcons.square_arrow_right,
                  color: context.resolve(AppColors.danger),
                ),
                title: Text(
                  'Sair da conta',
                  style: AppTypography.callout.copyWith(
                    color: context.resolve(AppColors.danger),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                onTap: () => Navigator.of(context).pop(true),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile});

  final SettingsProfile profile;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 72,
          height: 72,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: context.resolve(AppColors.primarySoft),
          ),
          child: Text(
            profile.initials,
            style: AppTypography.brand(
              24,
              weight: FontWeight.w700,
            ).copyWith(color: context.resolve(AppColors.onPrimarySoft)),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          profile.name,
          textAlign: TextAlign.center,
          style: AppTypography.title2.copyWith(color: context.resolve(AppColors.text)),
        ),
        const SizedBox(height: 2),
        Text(
          '@${profile.username} · ${profile.roleLabel}',
          style: AppTypography.subheadline.copyWith(
            color: context.resolve(AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Text(
        text.toUpperCase(),
        style: AppTypography.eyebrow.copyWith(color: context.resolve(AppColors.textSecondary)),
      ),
    );
  }
}

class _Card extends StatelessWidget {
  const _Card({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.card),
      child: ColoredBox(color: context.resolve(AppColors.surface), child: child),
    );
  }
}
