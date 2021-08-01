import 'package:jwt_decoder/jwt_decoder.dart';

class Usuario {
  String accessToken;
  String name;

  Usuario({this.accessToken});

  Usuario.fromJson(Map<String, dynamic> json) {
    accessToken = json['access_token'];
    Map<String, dynamic> decodedToken = JwtDecoder.decode(accessToken);
    name = decodedToken['userName'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['access_token'] = this.accessToken;
    return data;
  }
}
