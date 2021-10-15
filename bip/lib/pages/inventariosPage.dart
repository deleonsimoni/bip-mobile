import 'dart:convert';

import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/detalheInventarioPage.dart';
import 'package:bip/pages/homePage.dart';
import 'package:bip/pages/loginPage.dart';
import 'package:bip/services/inventario.api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventariosPage extends StatefulWidget {
  @override
  _InventariosPageState createState() => _InventariosPageState();
}

class _InventariosPageState extends State<InventariosPage> {
  var inventarios = new List<InventarioList>();

  _getInventarios() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    var token = prefs.get('tk');
    InventarioApi.getInventario(prefs.get('tk')).then((response) {
      setState(() {
        Iterable lista = json.decode(response.body);
        inventarios = lista.map((e) => InventarioList.fromJson(e)).toList();
      });
    });
  }

  _detalharInventario(inventario) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DetalheInventariosPage(inventario)));
  }

  _InventariosPageState() {
    _getInventarios();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //leading: Text('B.I.P'),
          title: Text('Inventários'),
          actions: [
            Icon(Icons.ac_unit),
          ],
        ),
        body: listaInventarios());
  }

  listaInventarios() {
    return ListView.builder(
        padding: const EdgeInsets.all(8),
        itemCount: inventarios.length,
        itemBuilder: (context, index) {
          return Card(
              child: ListTile(
            onTap: () => _detalharInventario(inventarios[index]),
            title: Text(inventarios[index].client.name,
                style: TextStyle(fontSize: 20.0, color: Colors.green)),
            subtitle: Text(inventarios[index].startDate.toString() +
                ' à ' +
                inventarios[index].endDate.toString()),
            leading: Icon(Icons.add_chart),
            trailing: Icon(Icons.amp_stories_rounded),
          ));
        });
  }
}
