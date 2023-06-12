import 'dart:io';
import 'package:foodtogo_customers/services/user_services.dart';
import 'package:foodtogo_customers/settings/secrets.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class FileServices {
  Future<String> uploadImage(File image) async {
    final token = UserServices.jwtToken;
    const fileAPISubUrl = 'api/FileAPI';

    var uri = Uri.http(Secrets.kFoodToGoAPILink, fileAPISubUrl);
    var request = http.MultipartRequest('POST', uri)
      ..headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('file', image.path));
    var response = await request.send();

    if (response.statusCode == 201) {
      var fileUrl = await response.stream.bytesToString();
      return fileUrl;
    } else {
      // Handle error
      throw Exception('Failed to upload image');
    }
  }

  Future<File> getImage(String filePath) async {
    final url = Uri.http(Secrets.kFoodToGoAPILink, filePath);
    final response = await http.get(url, headers: {
      'Authorization': 'Bearer ${UserServices.jwtToken}',
    });

    if (response.statusCode == 200) {
      final bytes = response.bodyBytes;
      final fileName = filePath.split('/').last;
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(bytes);
      return file;
    } else {
      // Handle error
      throw Exception('Failed to download image');
    }
  }

  Future<File> renameFile(File inputFile, String newName) async {
    final newPath = inputFile.parent.path + Platform.pathSeparator + newName;
    return await inputFile.rename(newPath);
  }
}
