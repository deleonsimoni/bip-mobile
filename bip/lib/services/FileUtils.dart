import 'package:path_provider/path_provider.dart';
import 'dart:io';

class FileUtils {
  write(String text, String idInventory) async {
    final Directory directory = await getApplicationDocumentsDirectory();
    final File file = File('${directory.path}/${idInventory}');
    await file.writeAsString(text);
  }

  Future<String> read(String idInventory) async {
    String text;
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/${idInventory}');
      text = await file.readAsString();
    } catch (e) {
      print("Couldn't read file");
    }
    return text;
  }

  Future<bool> checkExistFile(String idInventory) async {
    bool text;
    try {
      final Directory directory = await getApplicationDocumentsDirectory();
      final File file = File('${directory.path}/${idInventory}');
      return file != null ? true : false;
    } catch (e) {
      print("Couldn't read file");
      return false;
    }
  }
}
