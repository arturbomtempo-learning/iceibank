import 'package:flutter/cupertino.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/domain/models/leader_status.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class ConsensusStrip extends StatelessWidget {
  const ConsensusStrip({super.key, required this.status});

  final LeaderStatus status;

  @override
  Widget build(BuildContext context) {
    final consensus = status.consensus;
    final message = _message(consensus);
    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    final (Color background, Color foreground) = switch (consensus) {
      Consensus.agreed => (
        context.resolve(AppColors.primarySoft),
        context.resolve(AppColors.onPrimarySoft),
      ),
      Consensus.electing => (
        context.resolve(AppColors.fill),
        context.resolve(AppColors.textSecondary),
      ),
      Consensus.leaderUnreachable || Consensus.divergent => (
        context.resolve(AppColors.dangerSoft),
        context.resolve(AppColors.danger),
      ),
    };

    final Widget icon = switch (consensus) {
      Consensus.agreed => Icon(CupertinoIcons.checkmark_circle_fill, size: 18, color: foreground),
      Consensus.electing => const CupertinoActivityIndicator(radius: 8),
      Consensus.leaderUnreachable => Icon(
        CupertinoIcons.exclamationmark_triangle_fill,
        size: 18,
        color: foreground,
      ),
      Consensus.divergent => Icon(CupertinoIcons.arrow_branch, size: 18, color: foreground),
    };

    return Semantics(
      liveRegion: consensus != Consensus.agreed,
      child: AnimatedSize(
        duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        alignment: Alignment.topCenter,
        child: AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 280),
          child: Container(
            key: ValueKey(message),
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox.square(dimension: 18, child: Center(child: icon)),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Text(
                    message,
                    style: AppTypography.footnote.copyWith(color: foreground, height: 1.35),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _message(Consensus consensus) {
    final online = status.onlineProbes;
    final count = '${online.length} de ${AgencyEndpoints.count} agências no ar';

    return switch (consensus) {
      Consensus.agreed when online.length == AgencyEndpoints.count =>
        '$count. Todas reconhecem a Agência ${status.leaderId}.',
      Consensus.agreed => '$count. As ativas reconhecem a Agência ${status.leaderId}.',
      Consensus.electing => 'Eleição em andamento: $count, nenhuma com líder definida.',
      Consensus.leaderUnreachable =>
        'A Agência ${status.leaderId} ainda é reconhecida como líder, mas não responde. '
            'O heartbeat vai detectar a queda e eleger outra em instantes.',
      Consensus.divergent =>
        'As agências ainda não concordam sobre a líder: ${_views(online)}. '
            'O anúncio da nova líder resolve isso em instantes.',
    };
  }

  String _views(List<AgencyProbe> online) {
    final parts = [
      for (final probe in online)
        probe.leaderId == null
            ? 'a Agência ${probe.agencyId} está em eleição'
            : 'a Agência ${probe.agencyId} vê a ${probe.leaderId}',
    ];
    if (parts.length < 2) return parts.join();
    return '${parts.sublist(0, parts.length - 1).join(', ')} e ${parts.last}';
  }
}
