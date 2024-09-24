class GeoBoundariesModel {
  double? latitude;
  double? longitude;
  int? createdByUserId;
  String? createdDate;
  int? updatedByUserId;
  String? updatedDate;
  int? serverUpdatedStatus;

  GeoBoundariesModel({
    this.latitude,
    this.longitude,
    this.createdByUserId,
    this.createdDate,
    this.updatedByUserId,
    this.updatedDate,
    this.serverUpdatedStatus,
  });

  factory GeoBoundariesModel.fromMap(Map<String, dynamic> json) {
    return GeoBoundariesModel(
      latitude: json['Latitude'],
      longitude: json['Longitude'],
      createdByUserId: json['CreatedByUserId'],
      createdDate: json['CreatedDate'],
      updatedByUserId: json['UpdatedByUserId'],
      updatedDate: json['UpdatedDate'],
      serverUpdatedStatus: json['ServerUpdatedStatus'],
    );
  }

  // Convert the model to a Map
  Map<String, dynamic> toMap() {
    return {
      'Latitude': latitude,
      'Longitude': longitude,
      'CreatedByUserId': createdByUserId,
      'CreatedDate': createdDate,
      'UpdatedByUserId': updatedByUserId,
      'UpdatedDate': updatedDate,
      'ServerUpdatedStatus': serverUpdatedStatus,
    };
  }
}
