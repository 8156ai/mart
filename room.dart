class Room {
  final String id;
  final String name;
  final double fabricMeters;
  final double clientPrice;
  final double fabricCost;
  final double sewingCostSeamstress;
  final double sewingCostMy;
  final double profileCost;
  final double profileMarkup;
  final double totalCost;
  final String comment;
  final String contacts;
  final String cuttingInfo;
  final bool isCompleted;
  final Map<String, dynamic> technicalSpecs;
  final DateTime createdAt;
  final DateTime? clientDeadline;
  final DateTime? seamstressDeadline;

  Room({
    required this.id,
    required this.name,
    required this.fabricMeters,
    required this.clientPrice,
    required this.fabricCost,
    required this.sewingCostSeamstress,
    required this.sewingCostMy,
    required this.profileCost,
    required this.profileMarkup,
    required this.totalCost,
    required this.comment,
    this.contacts = '',
    this.cuttingInfo = '',
    this.isCompleted = false,
    required this.technicalSpecs,
    DateTime? createdAt,
    this.clientDeadline,
    this.seamstressDeadline,
  }) : createdAt = createdAt ?? DateTime.now();

  double get profit => clientPrice - totalCost;

  Room copyWith({
    String? name,
    double? fabricMeters,
    double? clientPrice,
    double? fabricCost,
    double? sewingCostSeamstress,
    double? sewingCostMy,
    double? profileCost,
    double? profileMarkup,
    double? totalCost,
    String? comment,
    String? contacts,
    String? cuttingInfo,
    bool? isCompleted,
    Map<String, dynamic>? technicalSpecs,
    DateTime? clientDeadline,
    DateTime? seamstressDeadline,
  }) {
    return Room(
      id: id,
      name: name ?? this.name,
      fabricMeters: fabricMeters ?? this.fabricMeters,
      clientPrice: clientPrice ?? this.clientPrice,
      fabricCost: fabricCost ?? this.fabricCost,
      sewingCostSeamstress: sewingCostSeamstress ?? this.sewingCostSeamstress,
      sewingCostMy: sewingCostMy ?? this.sewingCostMy,
      profileCost: profileCost ?? this.profileCost,
      profileMarkup: profileMarkup ?? this.profileMarkup,
      totalCost: totalCost ?? this.totalCost,
      comment: comment ?? this.comment,
      contacts: contacts ?? this.contacts,
      cuttingInfo: cuttingInfo ?? this.cuttingInfo,
      isCompleted: isCompleted ?? this.isCompleted,
      technicalSpecs: technicalSpecs ?? this.technicalSpecs,
      createdAt: createdAt,
      clientDeadline: clientDeadline ?? this.clientDeadline,
      seamstressDeadline: seamstressDeadline ?? this.seamstressDeadline,
    );
  }
}