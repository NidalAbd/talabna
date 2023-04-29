class Reports{
final int userId;
final int id;
final int reportableId;
final String reportableType;
final String reason;

  Reports({
    required this.userId,
    required this.reason,
    required this.id,
    required this.reportableId,
    required this.reportableType,
  });
  
  factory Reports.fromJson(Map<String , dynamic> json){
    return Reports(
        userId: json['user_id'],
        reason: json['reason'],
        id: json['id'],
        reportableId: json['reportable_id'],
        reportableType: json['reportable_type'],
    );

  }
  Map<String , dynamic> toJson(){
      return {
        'id' : id,
        'userId' : userId,
        'reason' : reason,
        'reportableId' : reportableId,
        'reportableType' : reportableType,
      };
  }
}