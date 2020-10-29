class ConsignmentStatus {
  String status;
  String stage;
  String message;
  String details;
  String code;
  ConsignmentPosition data;

  ConsignmentStatus(
      {this.status,
      this.stage,
      this.message,
      this.details,
      this.code,
      this.data});

  factory ConsignmentStatus.fromJson(Map<String, dynamic> json) {
    return ConsignmentStatus(
        code: json['code'],
        details: json['details'],
        message: json['message'],
        stage: json['stage'],
        status: json['status'],
        data: ConsignmentPosition.fromJson(json['data']));
  }
}

class ConsignmentPosition {
  String timestamp;
  double longitude;
  double latitude;
  String customkey;

  ConsignmentPosition(
      {this.customkey, this.latitude, this.longitude, this.timestamp});

  factory ConsignmentPosition.fromJson(Map<String, dynamic> json) {
    if (json == null) {
      return null;
    } else {
      return ConsignmentPosition(
          customkey: json['customkey'],
          latitude: json['latitude'],
          longitude: json['longitude'],
          timestamp: json['timestamp']);
    }
  }
}
