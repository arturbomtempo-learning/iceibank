import 'package:flutter/cupertino.dart';
import 'package:iceibank/config/agency_endpoints.dart';
import 'package:iceibank/domain/models/leader_status.dart';
import 'package:iceibank/ui/core/themes/app_colors.dart';
import 'package:iceibank/ui/core/themes/app_spacing.dart';
import 'package:iceibank/ui/core/themes/app_typography.dart';

class AgencyNetwork extends StatelessWidget {
  const AgencyNetwork({super.key, required this.status, required this.isOffline});

  final LeaderStatus? status;
  final bool isOffline;

  AgencyProbe? _probeFor(int agencyId) {
    if (isOffline) return AgencyProbe.offline(agencyId: agencyId);
    return status?.probeFor(agencyId);
  }

  @override
  Widget build(BuildContext context) {
    final ids = AgencyEndpoints.ids;
    final leaderId = isOffline ? null : status?.leaderId;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (final agencyId in ids) ...[
          AgencyNode(
            agencyId: agencyId,
            probe: _probeFor(agencyId),
            isLeader: agencyId == leaderId,
            headlineLeaderId: leaderId,
            pingSignal: status?.checkedAt,
          ),
          if (agencyId != ids.last)
            Expanded(
              child: _Link(
                isActive:
                    (_probeFor(agencyId)?.isOnline ?? false) &&
                    (_probeFor(agencyId + 1)?.isOnline ?? false),
              ),
            ),
        ],
      ],
    );
  }
}

class _Link extends StatelessWidget {
  const _Link({required this.isActive});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: AgencyNode.size / 2 - 1),
      child: AnimatedContainer(
        duration: MediaQuery.disableAnimationsOf(context)
            ? Duration.zero
            : const Duration(milliseconds: 420),
        height: 2,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          color: isActive
              ? AppColors.brandLight.withValues(alpha: 0.55)
              : context.resolve(AppColors.fill),
        ),
      ),
    );
  }
}

class AgencyNode extends StatefulWidget {
  const AgencyNode({
    super.key,
    required this.agencyId,
    required this.probe,
    required this.isLeader,
    required this.headlineLeaderId,
    required this.pingSignal,
  });

  static const double size = 48;

  final int agencyId;
  final AgencyProbe? probe;
  final bool isLeader;
  final int? headlineLeaderId;
  final Object? pingSignal;

  @override
  State<AgencyNode> createState() => _AgencyNodeState();
}

class _AgencyNodeState extends State<AgencyNode> with SingleTickerProviderStateMixin {
  late final AnimationController _ping = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  );

  @override
  void didUpdateWidget(AgencyNode oldWidget) {
    super.didUpdateWidget(oldWidget);
    final answered = widget.probe?.isOnline ?? false;
    if (answered &&
        widget.pingSignal != oldWidget.pingSignal &&
        !MediaQuery.disableAnimationsOf(context)) {
      _ping.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ping.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final probe = widget.probe;
    final isKnown = probe != null;
    final isOnline = probe?.isOnline ?? false;
    final isLeader = widget.isLeader;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final duration = reduceMotion ? Duration.zero : const Duration(milliseconds: 380);

    final danger = context.resolve(AppColors.danger);
    final secondary = context.resolve(AppColors.textSecondary);
    final tertiary = context.resolve(AppColors.textTertiary);

    final circleColor = switch ((isKnown, isOnline, isLeader)) {
      (_, true, true) => null,
      (true, false, _) => context.resolve(AppColors.dangerSoft),
      _ => context.resolve(AppColors.fill),
    };
    final foreground = switch ((isKnown, isOnline, isLeader)) {
      (_, true, true) => AppColors.white,
      (true, false, _) => danger,
      _ => context.resolve(AppColors.text),
    };

    final latency = probe?.latency;
    final (String health, Color healthColor) = switch ((isKnown, isOnline)) {
      (false, _) => ('', tertiary),
      (true, false) => ('Fora do ar', danger),
      (true, true) => (
        '${isLeader ? 'Líder · ' : ''}${latency?.inMilliseconds ?? 0} ms',
        isLeader ? context.resolve(AppColors.primary) : secondary,
      ),
    };

    final view = probe?.isOnline ?? false ? probe?.leaderId : null;
    final disagrees = isOnline && view != widget.headlineLeaderId;
    final viewLabel = switch ((isOnline, view)) {
      (false, _) when isKnown && isLeader => 'era a líder',
      (false, _) => '',
      (true, null) => 'em eleição',
      (true, final int id) => 'vê a $id',
    };

    return Semantics(
      label: _semantics(isKnown, isOnline, isLeader, latency, view),
      child: ExcludeSemantics(
        child: SizedBox(
          width: 92,
          child: Column(
            children: [
              SizedBox.square(
                dimension: AgencyNode.size,
                child: Stack(
                  clipBehavior: Clip.none,
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _ping,
                      builder: (context, _) {
                        final progress = _ping.value;
                        if (progress == 0 || progress == 1) return const SizedBox.shrink();
                        return Transform.scale(
                          scale: 1 + progress * 0.6,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: AppColors.brandLight.withValues(alpha: 0.5 * (1 - progress)),
                                width: 2,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    AnimatedContainer(
                      duration: duration,
                      curve: Curves.easeOutCubic,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: circleColor,
                        gradient: circleColor == null
                            ? const LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [AppColors.brandLight, AppColors.brand],
                              )
                            : null,
                        border: isLeader && !isOnline && isKnown
                            ? Border.all(color: danger, width: 2)
                            : null,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.brand.withValues(
                              alpha: isLeader && isOnline ? 0.35 : 0,
                            ),
                            blurRadius: isLeader && isOnline ? 18 : 0,
                            spreadRadius: isLeader && isOnline ? 1 : 0,
                          ),
                        ],
                      ),
                      child: AnimatedSwitcher(
                        duration: duration,
                        child: isKnown && !isOnline
                            ? Icon(
                                CupertinoIcons.wifi_slash,
                                key: const ValueKey('offline'),
                                size: 18,
                                color: foreground,
                              )
                            : Text(
                                '${widget.agencyId}',
                                key: const ValueKey('online'),
                                style: AppTypography.brand(18).copyWith(color: foreground),
                              ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Agência ${widget.agencyId}',
                style: AppTypography.caption.copyWith(color: context.resolve(AppColors.text)),
              ),
              const SizedBox(height: 2),
              _NodeLine(
                text: health,
                style: AppTypography.caption.copyWith(
                  color: healthColor,
                  fontWeight: isLeader ? FontWeight.w700 : FontWeight.w500,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
                duration: duration,
              ),
              _NodeLine(
                text: viewLabel,
                style: AppTypography.caption.copyWith(
                  color: disagrees || (isLeader && !isOnline) ? danger : tertiary,
                  fontWeight: disagrees || (isLeader && !isOnline)
                      ? FontWeight.w700
                      : FontWeight.w500,
                ),
                duration: duration,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _semantics(bool isKnown, bool isOnline, bool isLeader, Duration? latency, int? view) {
    final name = 'Agência ${widget.agencyId}';
    if (!isKnown) return name;
    if (!isOnline) return '$name fora do ar${isLeader ? ', era a líder' : ''}';
    final role = isLeader ? ', líder' : '';
    final seen = view == null ? 'em eleição' : 'reconhece a Agência $view';
    return '$name no ar$role, ${latency?.inMilliseconds ?? 0} milissegundos, $seen';
  }
}

class _NodeLine extends StatelessWidget {
  const _NodeLine({required this.text, required this.style, required this.duration});

  final String text;
  final TextStyle style;
  final Duration duration;

  @override
  Widget build(BuildContext context) {
    return AnimatedDefaultTextStyle(
      duration: duration,
      style: style,
      child: Text(
        text,
        maxLines: 1,
        softWrap: false,
        textAlign: TextAlign.center,
        strutStyle: const StrutStyle(forceStrutHeight: true),
      ),
    );
  }
}
