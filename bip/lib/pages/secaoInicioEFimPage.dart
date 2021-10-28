import 'dart:async';
import 'dart:io';

import 'package:bip/models/bip.dart';
import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/detalheInventarioPage.dart';
import 'package:bip/pages/secaoPage.dart';
import 'package:bip/services/Utils.dart';
import 'package:bip/services/databaseHandler.dart';
import 'package:bip/services/inventario.api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class SecaoInicioEFimPage extends StatefulWidget {
  InventarioList inventario;
  int secao;
  String secaoText;
  DatabaseHandler handler;
  List<String> itensClient;
  SecaoInicioEFimPage(this.inventario, this.itensClient);

  @override
  State<StatefulWidget> createState() {
    return _SecaoInicioEFimState(this.inventario, this.itensClient);
  }
}

class _SecaoInicioEFimState extends State<SecaoInicioEFimPage> {
  String usuario = '';
  InventarioList inventario;
  List<Bip> bips = [];
  int secao;
  String secaoText;
  FocusNode nodeFirst = FocusNode();
  FocusNode nodeSecond = FocusNode();
  List<String> itensClient;
  _SecaoInicioEFimState(this.inventario, this.itensClient);
  final ctrlInicio = TextEditingController();
  final ctrlFim = TextEditingController();
  DatabaseHandler handler;

  @override
  void initState() {
    ctrlInicio.addListener(() {
      FocusScope.of(context).requestFocus(nodeSecond);
    });

    super.initState();
  }

  _registrar() async {
    EasyLoading.show(status: "Aguarde...");
    if (ctrlInicio.text == "" || ctrlInicio == null) {
      EasyLoading.showError('Preencha o inicio da seção');
      return;
    }

    if (ctrlFim.text == "" || ctrlFim == null) {
      EasyLoading.showError('Preencha o fim da seção');
      return;
    }

    if (!Utils.isNumeric(ctrlFim.text) || !Utils.isNumeric(ctrlInicio.text)) {
      EasyLoading.showError('As seções devem ser númericas');
      return;
    }

    this.handler = DatabaseHandler();
    await handler.insertSecaoInicioEFim(
        inventario.sId, int.parse(ctrlInicio.text), int.parse(ctrlFim.text));

    EasyLoading.dismiss();

    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => DetalheInventariosPage(inventario, itensClient)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        //leading: Text('B.I.P'),
        title: Text('Cadastro de Seção'),
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
                  showCursor: true,
                  focusNode: nodeFirst,
                  readOnly: true,
                  controller: ctrlInicio,
                  decoration: InputDecoration(
                    hintText: 'Início Seção',
                    filled: true,
                    prefixIcon: Icon(
                      Icons.border_top,
                      size: 28.0,
                    ),
                  ),
                ),
              ),
              Container(
                  margin: EdgeInsets.only(left: 16.0),
                  child: TextFormField(
                    controller: ctrlFim,
                    showCursor: true,
                    readOnly: true,
                    focusNode: nodeSecond,
                    decoration: InputDecoration(
                      hintText: 'Fim Seção',
                      filled: true,
                      prefixIcon: Icon(
                        Icons.border_bottom,
                        size: 28.0,
                      ),
                    ),
                  )),
              Divider(),
              ButtonTheme(
                child: ElevatedButton(
                  onPressed: () {
                    _registrar();
                  },
                  child: Text(
                    "Cadastrar",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 100),
                    primary: Colors.green, // background
                    onPrimary: Colors.white, // foreground
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
