import 'package:path_provider/path_provider.dart';
import 'dart:io';

class Utils {
  static bool isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.parse(s, (e) => null) != null;
  }
}
