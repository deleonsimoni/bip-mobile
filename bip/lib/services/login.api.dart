import 'dart:convert';

import 'package:bip/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class LoginApi {
  static Future<Usuario> login(String user, String password) async {
    var url = Uri.http('10.0.2.2:3000', '/auth/login');
    //  Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

    var header = {"Content-type": "application/json"};
    Map params = {"username": user, "password": password};

    var body = json.encode(params);

    var response = await http.post(url, headers: header, body: body);
    if (response.statusCode == 201) {
      Map mapResponse = json.decode(response.body);
      var _prefs = await SharedPreferences.getInstance();
      _prefs.setString("tk", mapResponse['access_token']);
      return Usuario.fromJson(mapResponse);
    } else {
      return null;
    }
  }
}
