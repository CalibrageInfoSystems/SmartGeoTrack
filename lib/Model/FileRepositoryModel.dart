class FileRepositoryModel {
  final String leadsCode;
  final String? fileName;       // Nullable
  final String? fileLocation;   // Nullable
  final String? fileExtension;  // Nullable
  final bool isActive;
  final int createdByUserId;
  final String createdDate;     // This should not be nullable
  final int updatedByUserId;
  final String updatedDate;     // This should not be nullable
  final bool serverUpdatedStatus;

  FileRepositoryModel({
    required this.leadsCode,
    this.fileName,              // No need for 'required'
    this.fileLocation,          // No need for 'required'
    this.fileExtension,         // No need for 'required'
    required this.isActive,
    required this.createdByUserId,
    required this.createdDate,
    required this.updatedByUserId,
    required this.updatedDate,
    required this.serverUpdatedStatus,
  });

  // Factory method to create an instance from a JSON map
  factory FileRepositoryModel.fromJson(Map<String, dynamic> json) {
    return FileRepositoryModel(
      leadsCode: json['leadsCode'] ?? '',  // Ensure it has a default value
      fileName: json['FileName'],            // Check the key here
      fileLocation: json['FileLocation'],    // Check the key here
      fileExtension: json['FileExtension'],  // Check the key here
      isActive: json['IsActive'] == 1,       // Handle conversion from int to bool
      createdByUserId: json['CreatedByUserId'] ?? 0, // Default to 0 if null
      createdDate: json['CreatedDate'] ?? '', // Ensure it has a default value
      updatedByUserId: json['UpdatedByUserId'] ?? 0, // Default to 0 if null
      updatedDate: json['UpdatedDate'] ?? '', // Ensure it has a default value
      serverUpdatedStatus: json['ServerUpdatedStatus'] == 1, // Handle conversion from int to bool
    );
  }

  // Method to convert the object to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'leadsCode': leadsCode,
      'fileName': fileName,
      'fileLocation': fileLocation,
      'fileExtension': fileExtension,
      'isActive': isActive,
      'createdByUserId': createdByUserId,
      'CreatedDate': createdDate,
      'UpdatedByUserId': updatedByUserId,
      'UpdatedDate': updatedDate,
      'ServerUpdatedStatus': serverUpdatedStatus,
    };
  }
}
