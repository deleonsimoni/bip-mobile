import 'dart:io';

import 'package:bip/models/bip.dart';
import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/detalheInventarioPage.dart';
import 'package:bip/pages/secaoPage.dart';
import 'package:bip/services/databaseHandler.dart';
import 'package:bip/services/inventario.api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class BipPage extends StatefulWidget {
  InventarioList inventario;
  int secao;
  String secaoText;
  DatabaseHandler handler;

  BipPage(this.inventario, this.secao, this.secaoText);

  @override
  State<StatefulWidget> createState() {
    return _BipPageState(this.inventario, this.secao, this.secaoText);
  }
}

class _BipPageState extends State<BipPage> {
  String usuario = '';
  InventarioList inventario;
  List<Bip> bips = [];
  int secao;
  String secaoText;

  List<String> itensClient;
  _BipPageState(this.inventario, this.secao, this.secaoText);
  final ctrlRefer = TextEditingController();
  final ctrlQuantity = TextEditingController();
  final ctrlFinalize = TextEditingController();
  DatabaseHandler handler;

  @override
  void initState() {
    _getItensFromDB(inventario).then((value) => setState(() {
          EasyLoading.dismiss();
          itensClient = value;
        }));
    super.initState();
  }

  Future<List<String>> _getItensFromDB(inventario) async {
    EasyLoading.show(status: 'Preparando Bipagem');

    this.handler = DatabaseHandler();
    return await this.handler.getItenClient(inventario.sId);
  }

  _finalizarSecao() async {
    if (ctrlFinalize.text != null &&
        int.parse(ctrlFinalize.text) != bips.length) {
      await this.handler.deleteBip(secao);
      await this.handler.deleteSecao(secao);

      EasyLoading.addStatusCallback((status) {
        if (status == EasyLoadingStatus.dismiss) {
          EasyLoading.removeAllCallbacks();

          Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => DetalheInventariosPage(inventario)));
        }
      });
      EasyLoading.showInfo(
          'Quantidade informada não bate, favor bipar seção novamente');
      return;
    } else {
      EasyLoading.showSuccess('Seção contabilizada com sucesso');
      await this.handler.updateStatusSecao(secao, 1);

      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => DetalheInventariosPage(inventario)));
    }
  }

  _registrar() async {
    EasyLoading.show(status: "Aguarde...");
    if (ctrlRefer.text == "" || ctrlRefer == null) {
      EasyLoading.showError('Escaneie o código');
      return;
    }

    if (inventario.isQuantify &&
        (ctrlQuantity.text == "" || ctrlQuantity == null)) {
      EasyLoading.showError('Digite a quantidade');
      return;
    }

    final itemSelect = itensClient
        .firstWhere((barcode) => barcode == ctrlRefer.text, orElse: () {
      return null;
    });

    bool find = itemSelect != null ? true : false;

    Bip bip =
        new Bip(inventario.sId, secaoText, ctrlRefer.text, find, "device");

    this.handler = DatabaseHandler();
    await handler.insertBip(
        inventario.sId, secao, ctrlRefer.text, find, "device");
    bips.add(bip);
    ctrlQuantity.text = "";
    ctrlRefer.text = "";
    EasyLoading.dismiss();
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
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: (inventario.isQuantify)
                    ? TextFormField(
                        controller: ctrlQuantity,
                        decoration: InputDecoration(
                          hintText: 'Quantidade',
                          filled: true,
                          prefixIcon: Icon(
                            Icons.queue_rounded,
                            size: 28.0,
                          ),
                        ),
                      )
                    : SizedBox.shrink(),
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
