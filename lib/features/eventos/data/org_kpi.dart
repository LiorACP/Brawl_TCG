class OrgKpi {
  final int todayCount;
  final int totalEnrolled;
  final int newEnrollments;
  final double monthlyRevenue;

  const OrgKpi({
    required this.todayCount,
    required this.totalEnrolled,
    required this.newEnrollments,
    required this.monthlyRevenue,
  });

  String get revenueLabel {
    final v = monthlyRevenue.toStringAsFixed(0);
    return '€ $v';
  }
}
