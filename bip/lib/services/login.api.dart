import 'dart:convert';
import 'dart:io';

import 'package:bip/models/usuario.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginApi {
  static Future<Usuario> login(String user, String password) async {
    EasyLoading.show(status: 'Aguarde...');

    var url = Uri.http('10.0.2.2:3000', '/user/auth/login');
    //  Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

    var header = {"Content-type": "application/json"};
    Map params = {"email": user, "password": password};

    var body = json.encode(params);

    var response = await http.post(url, headers: header, body: body);
    if (response.statusCode == 201) {
      EasyLoading.showSuccess('Bem vindo!');

      Map mapResponse = json.decode(response.body);
      Map<String, dynamic> decodedToken =
          JwtDecoder.decode(mapResponse['access_token']);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("tk", mapResponse['access_token']);
      prefs.setString("name", decodedToken['username']);

      return Usuario.fromJson(mapResponse);
    } else {
      EasyLoading.dismiss();

      return null;
    }
  }
}
