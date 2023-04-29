class PurchaseRequest {
  final int? id;
  final int? userId;
  final int? pointsRequested;
  final double? pricePerPoint;
  final double? totalPrice;
  final String? status;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  PurchaseRequest({
     this.id,
     this.userId,
     this.pointsRequested,
     this.pricePerPoint,
     this.totalPrice,
     this.status,
     this.createdAt,
     this.updatedAt,
  });

  factory PurchaseRequest.fromJson(Map<String, dynamic> json) {
    return PurchaseRequest(
      id: json['id'],
      userId: json['user_id'],
      pointsRequested: json['points_requested'],
      pricePerPoint: double.parse(json['price_per_point']),
      totalPrice: double.parse(json['total_price']),
      status: json['status'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'points_requested': pointsRequested,
      'price_per_point': pricePerPoint.toString(),
      'total_price': totalPrice.toString(),
      'status': status,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
