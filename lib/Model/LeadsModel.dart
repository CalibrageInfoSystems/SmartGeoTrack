// class LeadsModel {
//   int? isCompany;
//   String? code;
//   String? name;
//   String? phoneNumber;
//   String? email;
//   double? latitude;
//   double? longitude;
//   int? createdByUserId;
//   String? createdDate;
//
//   LeadsModel({
//     this.isCompany,
//     this.code,
//     this.name,
//     this.phoneNumber,
//     this.email,
//     this.latitude,
//     this.longitude,
//     this.createdByUserId,
//     this.createdDate,
//   });
//
//   factory LeadsModel.fromMap(Map<String, dynamic> json) {
//     return LeadsModel(
//       isCompany: json['IsCompany'],
//       code: json['Code'],
//       name: json['Name'],
//       phoneNumber: json['PhoneNumber'],
//       email: json['Email'],
//       latitude: json['Latitude'],
//       longitude: json['Longitude'],
//       createdByUserId: json['CreatedByUserId'],
//       createdDate: json['CreatedDate'],
//     );
//   }
// }
class LeadsModel {
  final bool isCompany;
  final String? code;
  final String? name;
  final String? companyName;
  final String? phoneNumber;
  final String? email;
  final String? comments;
  final double? latitude;
  final double?longitude;
  final int? createdByUserId;
  final DateTime? createdDate;
  final int? updatedByUserId;
  final DateTime? updatedDate;
  final int serverUpdatedStatus;

  LeadsModel({
    required this.isCompany,
    required this.code,
    required this.name,
    this.companyName,
    required this.phoneNumber,
    required this.email,
    required this.comments,
    required this.latitude,
    required this.longitude,
    required this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
    required this.serverUpdatedStatus,
  });

  // Factory method to create a Lead instance from a map
  factory LeadsModel.fromMap(Map<String, dynamic> map) {
    return LeadsModel(
      isCompany: map['IsCompany'] == 1,
      code: map['Code'],
      name: map['Name'],
      companyName: map['CompanyName'],
      phoneNumber: map['PhoneNumber'],
      email: map['Email'],
      comments: map['Comments'],
      latitude: map['Latitude'],
      longitude: map['Longitude'],
      createdByUserId: map['CreatedByUserId'],
      createdDate: DateTime.parse(map['CreatedDate']),
      updatedByUserId: map['UpdatedByUserId'],
      updatedDate: DateTime.parse(map['UpdatedDate']),
      serverUpdatedStatus: map['ServerUpdatedStatus'],
    );
  }

  // Method to convert a Lead instance to a map
  Map<String, dynamic> toMap() {
    return {
      'IsCompany': isCompany ? 1 : 0,
      'Code': code,
      'Name': name,
      'CompanyName': companyName,
      'PhoneNumber': phoneNumber,
      'Email': email,
      'Comments': comments,
      'Latitude': latitude,
      'Longitude': longitude,
      'CreatedByUserId': createdByUserId,
      'CreatedDate': createdDate!.toIso8601String(),
      'UpdatedByUserId': updatedByUserId,
      'UpdatedDate': updatedDate!.toIso8601String(),
      'ServerUpdatedStatus': serverUpdatedStatus,
    };
  }
}
