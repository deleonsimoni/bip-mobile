import 'package:intl/intl.dart';

class Bip {
  int id;
  String idInventario;
  String idSecao;
  String bip;
  bool isFounded;
  String device;

  Bip(this.idInventario, this.idSecao, this.bip, this.isFounded, this.device);

  Bip.fromJson(Map<String, dynamic> json) {
    idInventario = json['idInventario'];
    idSecao = json['idSecao'];
    bip = json['bip'];
    isFounded = json['isFounded'];
    device = json['device'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['idInventario'] = this.idInventario;
    data['idSecao'] = this.idSecao;
    data['bip'] = this.bip;
    data['isFounded'] = this.isFounded;
    data['device'] = this.device;
    return data;
  }
}
