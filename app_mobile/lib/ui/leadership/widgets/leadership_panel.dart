import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/domain/models/leader_status.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';
import 'package:iceibank/ui/core/widgets/app_notice.dart';
import 'package:iceibank/ui/leadership/view_models/leadership_view_model.dart';
import 'package:iceibank/utils/time.dart';

class LeadershipPanel extends StatefulWidget {
  const LeadershipPanel({super.key, required this.viewModel});

  final LeadershipViewModel viewModel;

  @override
  State<LeadershipPanel> createState() => _LeadershipPanelState();
}

class _LeadershipPanelState extends State<LeadershipPanel> {
  LeaderChange? _seenChange;

  @override
  void initState() {
    super.initState();
    _seenChange = widget.viewModel.lastChange;
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void didUpdateWidget(LeadershipPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewModel == widget.viewModel) return;
    oldWidget.viewModel.removeListener(_onChanged);
    _seenChange = widget.viewModel.lastChange;
    widget.viewModel.addListener(_onChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onChanged);
    super.dispose();
  }

  void _onChanged() {
    final change = widget.viewModel.lastChange;
    if (change != null && change != _seenChange) {
      _seenChange = change;
      HapticFeedback.mediumImpact();
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = widget.viewModel;
    final status = viewModel.status;
    final error = viewModel.errorMessage;
    final change = viewModel.lastChange;
    final isOffline = error != null;

    return Semantics(
      container: true,
      liveRegion: true,
      label: _semanticsLabel(status, isOffline),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.xl - 4),
        decoration: BoxDecoration(
          color: context.resolve(AppColors.surface),
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ExcludeSemantics(
              child: Row(
                children: [
                  _LiveIndicator(isLive: viewModel.isRunning && !isOffline),
                  const Spacer(),
                  Text(
                    'Atualiza a cada ${viewModel.interval.inSeconds} s',
                    style: AppTypography.footnote.copyWith(
                      color: context.resolve(AppColors.textTertiary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            ExcludeSemantics(
              child: _LeaderHeadline(
                status: status,
                lastKnownLeaderId: viewModel.lastKnownLeaderId,
                isOffline: isOffline,
              ),
            ),
            const SizedBox(height: AppSpacing.xl),
            ExcludeSemantics(
              child: _AgencyNodes(
                leaderId: isOffline ? null : status?.leaderId,
                sourceAgencyId: isOffline ? null : status?.sourceAgencyId,
                unreachableAgencies: isOffline
                    ? AgencyEndpoints.ids
                    : status?.unreachableAgencies ?? const [],
              ),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: change == null
                  ? const SizedBox(width: double.infinity)
                  : Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.xl),
                      child: _ChangeBanner(key: ValueKey(change), change: change),
                    ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (error != null)
              AppNotice(tone: AppNoticeTone.danger, message: error)
            else
              _Footer(status: status),
          ],
        ),
      ),
    );
  }

  String _semanticsLabel(LeaderStatus? status, bool isOffline) {
    if (isOffline) return 'Painel de liderança: nenhuma agência respondeu';
    if (status == null) return 'Painel de liderança: consultando as agências';
    final leaderId = status.leaderId;
    if (leaderId == null) return 'Painel de liderança: eleição em andamento';
    return 'Painel de liderança: a Agência $leaderId é a líder atual';
  }
}

class _LiveIndicator extends StatefulWidget {
  const _LiveIndicator({required this.isLive});

  final bool isLive;

  @override
  State<_LiveIndicator> createState() => _LiveIndicatorState();
}

class _LiveIndicatorState extends State<_LiveIndicator> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 1400),
  );

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _syncAnimation();
  }

  @override
  void didUpdateWidget(_LiveIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    _syncAnimation();
  }

  void _syncAnimation() {
    final shouldAnimate = widget.isLive && !MediaQuery.disableAnimationsOf(context);
    if (shouldAnimate && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!shouldAnimate && _controller.isAnimating) {
      _controller
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = context.resolve(widget.isLive ? AppColors.primary : AppColors.danger);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: 14,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final progress = _controller.value;
              return Stack(
                alignment: Alignment.center,
                children: [
                  if (widget.isLive)
                    Container(
                      width: 6 + 8 * progress,
                      height: 6 + 8 * progress,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: color.withValues(alpha: 0.35 * (1 - progress)),
                      ),
                    ),
                  Container(
                    width: 7,
                    height: 7,
                    decoration: BoxDecoration(shape: BoxShape.circle, color: color),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: 6),
        Text(
          widget.isLive ? 'AO VIVO' : 'SEM SINAL',
          style: AppTypography.eyebrow.copyWith(color: color),
        ),
      ],
    );
  }
}

class _LeaderHeadline extends StatelessWidget {
  const _LeaderHeadline({
    required this.status,
    required this.lastKnownLeaderId,
    required this.isOffline,
  });

  final LeaderStatus? status;
  final int? lastKnownLeaderId;
  final bool isOffline;

  @override
  Widget build(BuildContext context) {
    final text = context.resolve(AppColors.text);
    final secondary = context.resolve(AppColors.textSecondary);
    final leaderId = status?.leaderId;
    final lastKnown = lastKnownLeaderId;

    final (String caption, Widget headline, String key) = switch ((status, leaderId, isOffline)) {
      (_, _, true) => (
        lastKnown == null ? 'Agência líder' : 'Última líder conhecida',
        Text(
          lastKnown == null ? 'Indisponível' : 'Agência $lastKnown',
          style: AppTypography.title1.copyWith(color: secondary),
        ),
        'offline-$lastKnown',
      ),
      (null, _, _) => (
        'Agência líder',
        Row(
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(width: AppSpacing.md),
            Text('Consultando…', style: AppTypography.title1.copyWith(color: secondary)),
          ],
        ),
        'loading',
      ),
      (_, null, _) => (
        'Eleição em andamento',
        Row(
          children: [
            const CupertinoActivityIndicator(),
            const SizedBox(width: AppSpacing.md),
            Text('Escolhendo a líder', style: AppTypography.title1.copyWith(color: text)),
          ],
        ),
        'electing',
      ),
      (_, final int id, _) => (
        'Agência líder',
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('Agência $id', style: AppTypography.largeTitle.copyWith(color: text, height: 1)),
            const SizedBox(width: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 22,
                color: context.resolve(AppColors.primary),
              ),
            ),
          ],
        ),
        'leader-$id',
      ),
    };

    final reduceMotion = MediaQuery.disableAnimationsOf(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(caption, style: AppTypography.footnote.copyWith(color: secondary)),
        const SizedBox(height: AppSpacing.xs),
        AnimatedSwitcher(
          duration: reduceMotion ? Duration.zero : const Duration(milliseconds: 420),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          layoutBuilder: (current, previous) =>
              Stack(alignment: Alignment.centerLeft, children: [...previous, ?current]),
          transitionBuilder: (child, animation) => FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween(begin: const Offset(0, 0.35), end: Offset.zero).animate(animation),
              child: child,
            ),
          ),
          child: KeyedSubtree(key: ValueKey(key), child: headline),
        ),
      ],
    );
  }
}

class _AgencyNodes extends StatelessWidget {
  const _AgencyNodes({
    required this.leaderId,
    required this.sourceAgencyId,
    required this.unreachableAgencies,
  });

  final int? leaderId;
  final int? sourceAgencyId;
  final List<int> unreachableAgencies;

  @override
  Widget build(BuildContext context) {
    final ids = AgencyEndpoints.ids;
    final line = context.resolve(AppColors.fill);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final agencyId in ids) ...[
          _AgencyNode(
            agencyId: agencyId,
            role: switch (agencyId) {
              _ when agencyId == leaderId => _NodeRole.leader,
              _ when unreachableAgencies.contains(agencyId) => _NodeRole.unreachable,
              _ when agencyId == sourceAgencyId => _NodeRole.source,
              _ => _NodeRole.idle,
            },
          ),
          if (agencyId != ids.last)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: _AgencyNode.size / 2 - 1),
                child: Container(height: 2, color: line),
              ),
            ),
        ],
      ],
    );
  }
}

enum _NodeRole { leader, source, unreachable, idle }

class _AgencyNode extends StatelessWidget {
  const _AgencyNode({required this.agencyId, required this.role});

  static const double size = 48;

  final int agencyId;
  final _NodeRole role;

  @override
  Widget build(BuildContext context) {
    final isLeader = role == _NodeRole.leader;
    final isUnreachable = role == _NodeRole.unreachable;
    final duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : const Duration(milliseconds: 380);

    final numberColor = switch (role) {
      _NodeRole.leader => AppColors.white,
      _NodeRole.unreachable => context.resolve(AppColors.danger),
      _ => context.resolve(AppColors.text),
    };

    final (String label, Color labelColor) = switch (role) {
      _NodeRole.leader => ('Líder', context.resolve(AppColors.primary)),
      _NodeRole.unreachable => ('Sem resposta', context.resolve(AppColors.danger)),
      _NodeRole.source => ('Consultada', context.resolve(AppColors.textSecondary)),
      _NodeRole.idle => ('', context.resolve(AppColors.textTertiary)),
    };

    return SizedBox(
      width: 92,
      child: Column(
        children: [
          AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            width: size,
            height: size,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isLeader
                  ? null
                  : context.resolve(isUnreachable ? AppColors.dangerSoft : AppColors.fill),
              gradient: isLeader
                  ? const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.brandLight, AppColors.brand],
                    )
                  : null,
              boxShadow: [
                BoxShadow(
                  color: AppColors.brand.withValues(alpha: isLeader ? 0.35 : 0),
                  blurRadius: isLeader ? 18 : 0,
                  spreadRadius: isLeader ? 1 : 0,
                ),
              ],
            ),
            child: isUnreachable
                ? Icon(CupertinoIcons.wifi_slash, size: 18, color: numberColor)
                : Text('$agencyId', style: AppTypography.brand(18).copyWith(color: numberColor)),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Agência $agencyId',
            style: AppTypography.caption.copyWith(color: context.resolve(AppColors.text)),
          ),
          const SizedBox(height: 2),
          AnimatedDefaultTextStyle(
            duration: duration,
            style: AppTypography.caption.copyWith(
              color: labelColor,
              fontWeight: isLeader ? FontWeight.w700 : FontWeight.w500,
            ),
            child: Text(
              label,
              maxLines: 1,
              softWrap: false,
              textAlign: TextAlign.center,
              strutStyle: const StrutStyle(forceStrutHeight: true),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChangeBanner extends StatelessWidget {
  const _ChangeBanner({super.key, required this.change});

  final LeaderChange change;

  @override
  Widget build(BuildContext context) {
    final foreground = context.resolve(AppColors.onPrimarySoft);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.resolve(AppColors.primarySoft),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        children: [
          Icon(CupertinoIcons.arrow_2_circlepath, size: 18, color: foreground),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nova líder às ${formatClock(change.detectedAt)}',
                  style: AppTypography.subheadline.copyWith(
                    color: foreground,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'A liderança passou da Agência ${change.previousLeaderId} '
                  'para a Agência ${change.newLeaderId}.',
                  style: AppTypography.footnote.copyWith(color: foreground),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Footer extends StatelessWidget {
  const _Footer({required this.status});

  final LeaderStatus? status;

  @override
  Widget build(BuildContext context) {
    final current = status;
    final color = context.resolve(AppColors.textTertiary);

    return Row(
      children: [
        Icon(CupertinoIcons.dot_radiowaves_left_right, size: 15, color: color),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            current == null
                ? 'Perguntando às agências quem coordena o grupo'
                : 'Via Agência ${current.sourceAgencyId} · verificado às ${formatClock(current.checkedAt)}',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: AppTypography.footnote.copyWith(color: color),
          ),
        ),
      ],
    );
  }
}
