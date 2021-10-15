import 'package:intl/intl.dart';

class InventarioList {
  String sId;
  String startDate;
  String endDate;
  Client client;

  InventarioList({this.sId, this.startDate, this.endDate, this.client});

  InventarioList.fromJson(Map<String, dynamic> json) {
    sId = json['_id'];

    startDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(
        new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            .parse(json['startDate'])
            .toString()));
    endDate = DateFormat('dd/MM/yyyy').format(DateTime.parse(
        new DateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'")
            .parse(json['endDate'])
            .toString()));

    client =
        json['client'] != null ? new Client.fromJson(json['client']) : null;
  }
}

class Client {
  String createdAt;
  String sId;
  String name;
  String email;
  String document;
  Phones phones;
  Address address;
  String owner;
  int iV;

  Client(
      {this.createdAt,
      this.sId,
      this.name,
      this.email,
      this.document,
      this.phones,
      this.address,
      this.owner,
      this.iV});

  Client.fromJson(Map<String, dynamic> json) {
    createdAt = json['createdAt'];
    sId = json['_id'];
    name = json['name'];
    email = json['email'];
    document = json['document'];
    phones =
        json['phones'] != null ? new Phones.fromJson(json['phones']) : null;
    address =
        json['address'] != null ? new Address.fromJson(json['address']) : null;
    owner = json['owner'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['createdAt'] = this.createdAt;
    data['_id'] = this.sId;
    data['name'] = this.name;
    data['email'] = this.email;
    data['document'] = this.document;
    if (this.phones != null) {
      data['phones'] = this.phones.toJson();
    }
    if (this.address != null) {
      data['address'] = this.address.toJson();
    }
    data['owner'] = this.owner;
    data['__v'] = this.iV;
    return data;
  }
}

class Phones {
  String phone;
  String whatsapp;

  Phones({this.phone, this.whatsapp});

  Phones.fromJson(Map<String, dynamic> json) {
    phone = json['phone'];
    whatsapp = json['whatsapp'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['phone'] = this.phone;
    data['whatsapp'] = this.whatsapp;
    return data;
  }
}

class Address {
  String street;
  String complement;
  String number;
  String zip;
  String city;
  String district;
  String state;
  String country;

  Address(
      {this.street,
      this.complement,
      this.number,
      this.zip,
      this.city,
      this.district,
      this.state,
      this.country});

  Address.fromJson(Map<String, dynamic> json) {
    street = json['street'];
    complement = json['complement'];
    number = json['number'];
    zip = json['zip'];
    city = json['city'];
    district = json['district'];
    state = json['state'];
    country = json['country'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['street'] = this.street;
    data['complement'] = this.complement;
    data['number'] = this.number;
    data['zip'] = this.zip;
    data['city'] = this.city;
    data['district'] = this.district;
    data['state'] = this.state;
    data['country'] = this.country;
    return data;
  }
}
