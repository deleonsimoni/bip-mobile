import 'dart:convert';
import 'package:bip/models/bip.dart';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';

class InventarioApi {
  static Future getInventario(String token) async {
    var url = Uri.http('10.0.2.2:3000', '/inventory/inventaryUser');
    //  Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

    var header = {
      "Content-type": "application/json",
      'Authorization': 'Bearer $token',
    };

    return await http.get(url, headers: header);
  }

  static Future finalizarSecao(
      String inventario, String token, List<Bip> bips) async {
    var url = Uri.http('10.0.2.2:3000', '/inventory/finalizarSecao');

    var header = {
      "Content-type": "application/json",
      'Authorization': 'Bearer $token',
    };

    Map params = {"inventory": inventario, "bips": jsonEncode(bips)};

    var body = json.encode(params);

    return await http.post(url, headers: header, body: body);
  }

  static Future getItens(String id, String token) async {
    var url = Uri.http('10.0.2.2:3000', '/inventory/inventaryUser/$id/itens');
    //  Uri.https('www.googleapis.com', '/books/v1/volumes', {'q': '{http}'});

    var header = {
      "Content-type": "application/json",
      'Authorization': 'Bearer $token',
    };

    return await http.get(url, headers: header);
  }
}
