class AgencyProbe {
  const AgencyProbe.online({required this.agencyId, required this.leaderId, required this.latency})
    : isOnline = true;

  const AgencyProbe.offline({required this.agencyId})
    : isOnline = false,
      leaderId = null,
      latency = null;

  final int agencyId;
  final bool isOnline;
  final int? leaderId;
  final Duration? latency;
}

enum Consensus { agreed, leaderUnreachable, divergent, electing }

class LeaderStatus {
  const LeaderStatus({
    required this.leaderId,
    required this.sourceAgencyId,
    required this.probes,
    required this.checkedAt,
  });

  final int? leaderId;
  final int sourceAgencyId;
  final List<AgencyProbe> probes;
  final DateTime checkedAt;

  bool get isElecting => leaderId == null;

  List<AgencyProbe> get onlineProbes => probes.where((probe) => probe.isOnline).toList();

  List<int> get unreachableAgencies => [
    for (final probe in probes)
      if (!probe.isOnline) probe.agencyId,
  ];

  AgencyProbe? probeFor(int agencyId) {
    return probes.where((probe) => probe.agencyId == agencyId).firstOrNull;
  }

  Consensus get consensus {
    final views = onlineProbes.map((probe) => probe.leaderId).toSet();
    if (views.length > 1) return Consensus.divergent;

    final agreedLeader = views.firstOrNull;
    if (agreedLeader == null) return Consensus.electing;
    if (unreachableAgencies.contains(agreedLeader)) return Consensus.leaderUnreachable;
    return Consensus.agreed;
  }
}
