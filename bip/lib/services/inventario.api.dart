import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class InventarioApi {
  static Future getInventario(String token) async {
    var url = Uri.http('localhost:3000', '/inventory/inventaryUser');
    //  Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

    var header = {
      "Content-type": "application/json",
      'Authorization': 'Bearer $token',
    };

    return await http.get(url, headers: header);
  }
}
