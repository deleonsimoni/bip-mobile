import 'package:intl/intl.dart';

class Bip {
  String section;
  String device;
  int quantity;
  bool find;
  String refer;

  Bip(String section, String device, int quantity, bool find, String refer) {
    // There's a better way to do this, stay tuned.
    this.section = section;
    this.device = device;
    this.quantity = quantity;
    this.find = find;
    this.refer = refer;
  }

  Bip.fromJson(Map<String, dynamic> json) {
    section = json['section'];
    device = json['device'];
    quantity = json['quantity'];
    find = json['find'];
    refer = json['refer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['section'] = this.section;
    data['device'] = this.device;
    data['quantity'] = this.quantity;
    data['find'] = this.find;
    data['refer'] = this.refer;
    return data;
  }
}
