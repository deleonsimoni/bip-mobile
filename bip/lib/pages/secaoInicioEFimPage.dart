import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:async';

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
import 'package:flutter_zebra_datawedge/flutter_zebra_datawedge.dart';

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
  bool showKeyboard = true;
  List<String> itensClient;
  _SecaoInicioEFimState(this.inventario, this.itensClient);
  final ctrlInicio = TextEditingController();
  final ctrlFim = TextEditingController();
  DatabaseHandler handler;
  String _data = "waiting...";
  String _labelType = "waiting...";
  String _source = "waiting...";

  @override
  void initState() {
    ctrlInicio.addListener(() {
      if (showKeyboard == true && ctrlInicio.text != "") {
        FocusScope.of(context).requestFocus(nodeSecond);
      }
    });
    initDataWedgeListener();

    super.initState();
  }

  Future<void> initDataWedgeListener() async {
    FlutterZebraDataWedge.listenForDataWedgeEvent((response) {
      if (response != null && response is String)
        setState(() {
          Map<String, dynamic> jsonResponse;
          try {
            jsonResponse = json.decode(response);
          } catch (e) {
            //TODO handling
          }
          if (jsonResponse != null) {
            _data = jsonResponse["decodedData"];
            _labelType = jsonResponse["decodedLabelType"];
            _source = jsonResponse["decodedSource"];

            if (showKeyboard == true && ctrlInicio.text == "") {
              ctrlInicio.text = _data;
            } else if (showKeyboard == true && ctrlInicio.text != "") {
              ctrlFim.text = _data;
            }
          } else {
            _source = "An error occured";
          }
        });
    });
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
              /*Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text("Label Type: $_labelType"),
                    Text("Soruce: $_source"),
                    Text("Data: $_data")
                  ],
                ),
              ),*/
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: TextFormField(
                  autofocus: true,
                  showCursor: showKeyboard,
                  focusNode: nodeFirst,
                  readOnly: showKeyboard,
                  controller: ctrlInicio,
                  onTap: () {
                    setState(() {
                      showKeyboard = false;
                    });
                  },
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
                    showCursor: showKeyboard,
                    readOnly: showKeyboard,
                    focusNode: nodeSecond,
                    onTap: () {
                      setState(() {
                        showKeyboard = false;
                      });
                    },
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
