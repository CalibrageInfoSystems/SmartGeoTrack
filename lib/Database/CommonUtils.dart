import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CommonUtils {

  static Future<String> get3FFileRootPath() async {
    // Get the external storage directory
    Directory? root = await getExternalStorageDirectory();

    // Define the 3F_Files directory path
    String rootPath = '${root!.path}/SmartGeoTrack';

    // Create the directory if it doesn't exist
    Directory rootDirectory = Directory(rootPath);
    if (!await rootDirectory.exists()) {
      await rootDirectory.create(recursive: true);
    }

    // Return the absolute path of the directory
    return rootDirectory.path + Platform.pathSeparator;
  }
}
