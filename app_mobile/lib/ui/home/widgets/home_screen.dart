import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:iceibank/data/repositories/auth_repository.dart';
import 'package:iceibank/domain/models/session.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key, required this.authRepository});

  final AuthRepository authRepository;

  Future<void> _confirmSignOut(BuildContext context) async {
    final shouldSignOut = await showCupertinoModalPopup<bool>(
      context: context,
      builder: (context) => CupertinoActionSheet(
        title: const Text('Deseja sair da sua conta?'),
        actions: [
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Sair'),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Cancelar'),
        ),
      ),
    );

    if (shouldSignOut ?? false) {
      unawaited(authRepository.signOut());
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = authRepository.session;

    return CupertinoPageScaffold(
      child: CustomScrollView(
        slivers: [
          CupertinoSliverNavigationBar(
            largeTitle: const Text('Início'),
            trailing: CupertinoButton(
              padding: EdgeInsets.zero,
              onPressed: () => _confirmSignOut(context),
              child: const Text('Sair'),
            ),
          ),
          if (session != null)
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.screen),
              sliver: SliverList.list(
                children: [
                  _WelcomeCard(session: session),
                  const SizedBox(height: AppSpacing.lg),
                  const AppNotice(
                    message:
                        'Saldo, depósitos, saques, transferências e o painel de liderança '
                        'chegam nas próximas etapas.',
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({required this.session});

  final Session session;

  String _formatTime(DateTime value) {
    final hours = value.hour.toString().padLeft(2, '0');
    final minutes = value.minute.toString().padLeft(2, '0');
    return '$hours:$minutes';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: context.resolve(AppColors.ink),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.xs),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.14),
              borderRadius: BorderRadius.circular(AppRadius.pill),
            ),
            child: Text(
              session.role.label,
              style: AppTypography.caption.copyWith(color: AppColors.accent),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            'Olá, ${session.username}',
            style: AppTypography.title1.copyWith(color: AppColors.white),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Sessão ativa até ${_formatTime(session.expiresAt)}.',
            style: AppTypography.subheadline.copyWith(
              color: context.resolve(AppColors.inkSecondary),
            ),
          ),
        ],
      ),
    );
  }
}
