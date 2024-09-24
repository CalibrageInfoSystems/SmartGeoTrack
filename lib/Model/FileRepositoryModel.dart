class FileRepositoryModel {
  String? leadsCode;
  String? fileName;
  String? fileLocation;
  String? fileExtension;
  int? isActive;

  FileRepositoryModel({
    this.leadsCode,
    this.fileName,
    this.fileLocation,
    this.fileExtension,
    this.isActive,
  });

  factory FileRepositoryModel.fromMap(Map<String, dynamic> json) {
    return FileRepositoryModel(
      leadsCode: json['LeadsCode'],
      fileName: json['FileName'],
      fileLocation: json['FileLocation'],
      fileExtension: json['FileExtension'],
      isActive: json['IsActive'],
    );
  }
}
