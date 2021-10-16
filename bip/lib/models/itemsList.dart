class ItemsList {
  List<Itens> itens;
  String createdAt;
  String sId;
  String inventory;
  int iV;

  ItemsList({this.itens, this.createdAt, this.sId, this.inventory, this.iV});

  ItemsList.fromJson(Map<String, dynamic> json) {
    if (json['itens'] != null) {
      itens = new List<Itens>();
      json['itens'].forEach((v) {
        itens.add(new Itens.fromJson(v));
      });
    }
    createdAt = json['createdAt'];
    sId = json['_id'];
    inventory = json['inventory'];
    iV = json['__v'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.itens != null) {
      data['itens'] = this.itens.map((v) => v.toJson()).toList();
    }
    data['createdAt'] = this.createdAt;
    data['_id'] = this.sId;
    data['inventory'] = this.inventory;
    data['__v'] = this.iV;
    return data;
  }
}

class Itens {
  String refer;

  Itens({this.refer});

  Itens.fromJson(Map<String, dynamic> json) {
    refer = json['refer'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['refer'] = this.refer;
    return data;
  }
}
