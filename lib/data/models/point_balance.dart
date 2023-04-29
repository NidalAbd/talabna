class PointBalance {
  final int userId;
  final int totalPoint;
  PointBalance( {
    required this.userId,
    required this.totalPoint,
  });
  factory PointBalance.fromJson(Map<String, dynamic> json) {
    return PointBalance(
      userId: json['userId'],
      totalPoint: json['pointBalance'],
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'totalPoint': totalPoint,
    };
  }
}
