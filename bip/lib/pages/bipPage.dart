import 'dart:io';

import 'package:bip/models/bip.dart';
import 'package:bip/models/inventarioList.dart';
import 'package:bip/models/itemsList.dart';
import 'package:bip/pages/inventariosPage.dart';
import 'package:bip/pages/loginPage.dart';
import 'package:bip/pages/secaoPage.dart';
import 'package:bip/services/inventario.api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:collection/collection.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class BipPage extends StatefulWidget {
  InventarioList inventario;
  List<ItemsList> items;
  String secao;
  BipPage(this.inventario, this.items, this.secao);

  @override
  State<StatefulWidget> createState() {
    return _BipPageState(this.inventario, this.items, this.secao);
  }
}

class _BipPageState extends State<BipPage> {
  String usuario = '';
  InventarioList inventario;
  List<Bip> bips = [];
  String secao;
  List<ItemsList> items;
  _BipPageState(this.inventario, this.items, this.secao);
  final ctrlRefer = TextEditingController();
  final ctrlQuantity = TextEditingController();
  final ctrlFinalize = TextEditingController();

  @override
  void initState() {
    _getThingsOnStartup().then((value) => setState(() {
          usuario = value;
        }));
    super.initState();
  }

  Future<String> _getThingsOnStartup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.get('name');
  }

  Future<void> sair() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  _finalizarSecao() async {
    if (ctrlFinalize.text != null &&
        int.parse(ctrlFinalize.text) != bips.length) {
      EasyLoading.showError(
          'Quantidade informada não bate, favor bipar seção novamente');
      sleep(Duration(seconds: 3));
      Navigator.push(context,
          MaterialPageRoute(builder: (context) => SecaoPage(inventario)));
      return;
    } else {
      EasyLoading.show(status: 'Finalizando Seção...');
      sleep(Duration(seconds: 3));

      SharedPreferences prefs = await SharedPreferences.getInstance();
      InventarioApi.finalizarSecao(inventario.sId, prefs.get('tk'), bips)
          .then((response) {
        if (response.status == 200) {
          EasyLoading.showSuccess('Seção cadastrada com sucesso');
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => SecaoPage(inventario)));
        } else {
          EasyLoading.showError(
              'Ocorreu algum erro, tente novamente mais tarde');
        }
      });
    }
  }

  _registrar() {
    if (ctrlRefer.text == "" || ctrlRefer == null) {
      EasyLoading.showError('Escaneie o código');
      return;
    }

    if (ctrlQuantity.text == "" || ctrlQuantity == null) {
      EasyLoading.showError('Digite a quantidade');
      return;
    }

    var itemSelect =
        items[0].itens.firstWhereOrNull((item) => item.refer == ctrlRefer.text);

    bool find = itemSelect != null ? true : false;

    Bip bip = new Bip(
        secao, "439895", int.parse(ctrlQuantity.text), find, ctrlRefer.text);
    bips.add(bip);
    ctrlQuantity.text = "";
    ctrlRefer.text = "";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: Text('B.I.P'),
        title: Text('Bipando...'),
        automaticallyImplyLeading: false,
        actions: [
          Icon(Icons.ac_unit),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Divider(),
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: TextFormField(
                  autofocus: true,
                  controller: ctrlRefer,
                  decoration: InputDecoration(
                    hintText: 'Código do Produto',
                    filled: true,
                    prefixIcon: Icon(
                      Icons.receipt_rounded,
                      size: 28.0,
                    ),
                  ),
                ),
              ),
              //if (true)
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: TextFormField(
                  controller: ctrlQuantity,
                  decoration: InputDecoration(
                    hintText: 'Quantidade',
                    filled: true,
                    prefixIcon: Icon(
                      Icons.queue_rounded,
                      size: 28.0,
                    ),
                  ),
                ),
              ),
              Divider(),
              ButtonTheme(
                child: ElevatedButton(
                  onPressed: () {
                    _registrar();
                  },
                  child: Text(
                    "Registrar",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),
                    primary: Colors.green, // background
                    onPrimary: Colors.white, // foreground
                  ),
                ),
              ),
              Divider(),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ButtonTheme(
                  height: 60.0,
                  child: ElevatedButton(
                    onPressed: () {
                      _showDialogFimSecao();
                    },
                    child: Text(
                      "Finalizar Seção",
                      style: TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      primary: Colors.red, // background
                      onPrimary: Colors.white, // foreground
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDialogFimSecao() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Quantidade de itens bipados'),
            content: Container(
              child: TextFormField(
                controller: ctrlFinalize,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Digite aqui',
                  filled: true,
                  prefixIcon: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 28.0,
                  ),
                ),
              ),
            ),
            actions: <Widget>[
              TextButton(
                  onPressed: () {
                    _dismissDialog();
                  },
                  child: Text('Voltar')),
              TextButton(
                onPressed: () {
                  _finalizarSecao();
                },
                child: Text('Confirmar!'),
              )
            ],
          );
        });
  }

  _dismissDialog() {
    Navigator.pop(context);
  }
}
