import 'dart:convert';
import 'dart:io';

class FileRepositoryModel {
  final String leadsCode;
  final String? fileName; // This will hold the Base64 string
  final String? fileLocation; // Nullable
  final String? fileExtension; // Nullable
  final bool isActive;
  final int createdByUserId;
  final String createdDate; // This should not be nullable
  final int updatedByUserId;
  final String updatedDate; // This should not be nullable
  final bool serverUpdatedStatus;

  FileRepositoryModel({
    required this.leadsCode,
    this.fileName, // Holds Base64 string
    this.fileLocation, // Nullable
    this.fileExtension, // Nullable
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

Future<String> convertFileToBase64(String filePath) async {
  final File file = File(filePath);
  if (await file.exists()) {
    List<int> fileBytes = await file.readAsBytes();
    return base64Encode(fileBytes); // Convert bytes to Base64
  } else {
    throw Exception("File not found");
  }
}

Future<void> prepareAndSendFile(String filePath, FileRepositoryModel model) async {
  try {
    // Convert the file to a Base64 string
    String base64File = await convertFileToBase64(filePath);

    // Create a new instance of FileRepositoryModel with the Base64 file name
    FileRepositoryModel updatedModel = FileRepositoryModel(
      leadsCode: model.leadsCode,
      fileName: base64File, // Set the file name as Base64 string
      fileLocation: model.fileLocation,
      fileExtension: model.fileExtension,
      isActive: model.isActive,
      createdByUserId: model.createdByUserId,
      createdDate: model.createdDate,
      updatedByUserId: model.updatedByUserId,
      updatedDate: model.updatedDate,
      serverUpdatedStatus: model.serverUpdatedStatus,
    );

    // Convert the model to JSON
    Map<String, dynamic> jsonData = updatedModel.toJson();

    // Here, you would send jsonData to your server
    // For example, using http package:
    // final response = await http.post(Uri.parse('your_api_url'), body: jsonData);

    // Print JSON for debugging
    print(jsonEncode(jsonData)); // Debugging: print the JSON being sent

  } catch (e) {
    print("Error: $e");
  }
}
