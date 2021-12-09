import 'dart:async';
import 'dart:convert';

import 'package:bip/models/bip.dart';
import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/detalheInventarioPage.dart';
import 'package:bip/pages/homePage.dart';
import 'package:bip/services/databaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_zebra_datawedge/flutter_zebra_datawedge.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class TestPage extends StatefulWidget {
  InventarioList inventario;
  bool isPermitAvulse;
  int secao;
  String secaoText;
  DatabaseHandler handler;
  List<String> itensClient;

  @override
  State<StatefulWidget> createState() {
    return _TestPageState();
  }
}

class _TestPageState extends State<TestPage> {
  _TestPageState();

  List<Bip> bips = [];
  bool showKeyboard = true;
  String _data = "";
  final ctrlRefer = TextEditingController();
  FocusNode nodeFirst = FocusNode();

  @override
  void initState() {
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
            ctrlRefer.text = _data;
            _registrar();
          } else {
            _data = "An error occured";
          }
        });
    });
  }

  _registrar() async {
    EasyLoading.show(status: "Aguarde...");
    if (ctrlRefer.text == "" || ctrlRefer == null) {
      EasyLoading.showError('Escaneie o código');
      FocusScope.of(context).requestFocus(nodeFirst);

      return;
    }

    bool find = false;

    Bip bip = new Bip('0', '0', ctrlRefer.text, find, "device");

    bips.add(bip);

    setState(() {
      ctrlRefer.text = "";
      showKeyboard = true;
      FocusScope.of(context).requestFocus(nodeFirst);
    });
    EasyLoading.dismiss();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Scaffold(
        appBar: AppBar(
          //leading: Text('B.I.P'),
          title: Text('Testes...'),
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
                Text(
                  'Cod: ${_data} BIPADOS: ${bips.length}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Divider(),
                Container(
                  margin: EdgeInsets.only(left: 16.0),
                  child: TextFormField(
                    autofocus: true,
                    showCursor: showKeyboard,
                    readOnly: showKeyboard,
                    focusNode: nodeFirst,
                    controller: ctrlRefer,
                    onTap: () {
                      setState(() {
                        showKeyboard = false;
                      });
                    },
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
                      minimumSize: Size(double.infinity, 100),
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
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => HomePage()));
                      },
                      child: Text(
                        "Voltar",
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
      ),
    );
  }

  _dismissDialog() {
    Navigator.pop(context);
  }
}
