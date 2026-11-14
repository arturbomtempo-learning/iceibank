class LeaderStatus {
  const LeaderStatus({
    required this.leaderId,
    required this.sourceAgencyId,
    required this.unreachableAgencies,
    required this.checkedAt,
  });

  final int? leaderId;
  final int sourceAgencyId;
  final List<int> unreachableAgencies;
  final DateTime checkedAt;

  bool get isElecting => leaderId == null;
}
