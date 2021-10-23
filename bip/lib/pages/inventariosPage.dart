import 'dart:convert';

import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/detalheInventarioPage.dart';
import 'package:bip/services/FileUtils.dart';
import 'package:bip/services/databaseHandler.dart';
import 'package:bip/services/inventario.api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class InventariosPage extends StatefulWidget {
  @override
  _InventariosPageState createState() => _InventariosPageState();
}

class _InventariosPageState extends State<InventariosPage> {
  var inventarios = new List<InventarioList>();
  DatabaseHandler handler;
  FileUtils fileUtils = new FileUtils();
  var existInDatabase = false;

  _syncornizeFileWithServer(inventario) async {
    EasyLoading.show(status: 'Sincronizando Arquivo...');

    this.handler = DatabaseHandler();
    existInDatabase = await this.handler.checkInventoryInBase(inventario.sId);
    if (existInDatabase) {
      EasyLoading.dismiss();
      _detalharInventario(inventario);
    } else {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      InventarioApi.getItens(inventario.sId, prefs.get('tk'))
          .then((response) async {
        await this.handler.insertInventory(inventario.sId);
        fileUtils.write(response.body, inventario.sId);

        EasyLoading.showSuccess('Arquivo sincronizado');
        _detalharInventario(inventario);
      });
    }
  }

  _getInventarios() async {
    EasyLoading.show(status: 'Aguarde...');
    SharedPreferences prefs = await SharedPreferences.getInstance();
    InventarioApi.getInventario(prefs.get('tk')).then((response) {
      setState(() {
        EasyLoading.dismiss();
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
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            color: Colors.red.shade700,
            elevation: 10,
            child: ListTile(
              onTap: () => _syncornizeFileWithServer(inventarios[index]),
              title: Text(inventarios[index].client.name,
                  style: TextStyle(fontSize: 20.0, color: Colors.white)),
              subtitle: Text(
                  inventarios[index].startDate.toString() +
                      ' à ' +
                      inventarios[index].endDate.toString(),
                  style: TextStyle(color: Colors.white70)),
              leading: Icon(Icons.add_chart),
              trailing: Icon(Icons.amp_stories_rounded),
            ),
          );
        });
  }
}
