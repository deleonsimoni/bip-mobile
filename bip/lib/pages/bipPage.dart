import 'dart:async';
import 'dart:convert';

import 'package:bip/models/bip.dart';
import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/detalheInventarioPage.dart';
import 'package:bip/services/databaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_zebra_datawedge/flutter_zebra_datawedge.dart';

class AlwaysDisabledFocusNode extends FocusNode {
  @override
  bool get hasFocus => false;
}

class BipPage extends StatefulWidget {
  InventarioList inventario;
  bool isPermitAvulse;
  int secao;
  String secaoText;
  int qtdSecaoContabilizada;
  DatabaseHandler handler;
  List<String> itensClient;
  BipPage(this.inventario, this.secao, this.secaoText,
      this.qtdSecaoContabilizada, this.itensClient, this.isPermitAvulse);

  @override
  State<StatefulWidget> createState() {
    return _BipPageState(this.inventario, this.secao, this.secaoText,
        this.qtdSecaoContabilizada, this.itensClient, this.isPermitAvulse);
  }
}

class _BipPageState extends State<BipPage> {
  String usuario = '';
  InventarioList inventario;
  bool isPermitAvulse;
  List<Bip> bips = [];
  int secao;
  int qtdSecaoContabilizada;
  String secaoText;
  bool showKeyboard = true;
  FocusNode nodeFirst = FocusNode();
  String _data = "";

  List<String> itensClient;
  _BipPageState(this.inventario, this.secao, this.secaoText,
      this.qtdSecaoContabilizada, this.itensClient, this.isPermitAvulse);
  final ctrlRefer = TextEditingController();
  final ctrlQuantity = TextEditingController();
  final ctrlFinalize = TextEditingController();
  DatabaseHandler handler;

  @override
  void initState() {
    initDataWedgeListener();
    /*new Timer(const Duration(milliseconds: 400), () {
      setState(() {
        ctrlRefer.text = "0000010010015";
      });
    });*/
    super.initState();
  }

  Future<void> initDataWedgeListener() async {
    FlutterZebraDataWedge.listenForDataWedgeEvent((response) {
      if (response != null && response is String && secaoText != null)
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
            _data = "An error occured bipando zebra";
          }
        });
    });
  }

  _finalizarSecao() async {
    secaoText = null;
    if (bips.length == 0) {
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  DetalheInventariosPage(inventario, this.itensClient)),
          (Route<dynamic> route) => false);
    } else {
      if (ctrlFinalize.text != null &&
          int.parse(ctrlFinalize.text) !=
              (bips.length + this.qtdSecaoContabilizada)) {
        await this.handler.deleteBip(secao);
        await this.handler.updateStatusSecao(secao, 0);

        //await this.handler.deleteSecao(secao);

        EasyLoading.addStatusCallback((status) {
          if (status == EasyLoadingStatus.dismiss) {
            EasyLoading.removeAllCallbacks();

            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        DetalheInventariosPage(inventario, this.itensClient)),
                (Route<dynamic> route) => false);
          }
        });
        EasyLoading.showInfo(
            'Quantidade informada não bate, favor bipar seção novamente');
        return;
      } else {
        EasyLoading.showSuccess('Seção contabilizada com sucesso');
        await this.handler.updateStatusSecao(secao, 1);

        Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    DetalheInventariosPage(inventario, this.itensClient)), (r) {
          return false;
        });
      }
    }
  }

  _registrar() async {
    EasyLoading.show(status: "Aguarde...");

    if (secaoText == null) {
      EasyLoading.dismiss();
      return;
    }

    if (ctrlRefer.text == "" || ctrlRefer == null) {
      EasyLoading.showError('Escaneie o código');
      FocusScope.of(context).requestFocus(nodeFirst);
      return;
    }

    if (inventario.isQuantify &&
        (ctrlQuantity.text == "" || ctrlQuantity == null)) {
      EasyLoading.showError('Digite a quantidade');
      return;
    }

    bool find = false;
    if (!isPermitAvulse) {
      final itemSelect = itensClient
          .firstWhere((barcode) => barcode == ctrlRefer.text, orElse: () {
        return null;
      });
      find = itemSelect != null ? true : false;
    }

    if (!find && !isPermitAvulse) {
      EasyLoading.showInfo('Atenção: Produto não catálogado');
      FocusScope.of(context).requestFocus(nodeFirst);
      return;
    } else {
      Bip bip =
          new Bip(inventario.sId, secaoText, ctrlRefer.text, find, "device");

      this.handler = DatabaseHandler();
      await handler.insertBip(
          inventario.sId, secao, ctrlRefer.text, find, "device");
      bips.add(bip);
      setState(() {
        ctrlQuantity.text = "";
        ctrlRefer.text = "";
        showKeyboard = true;
        FocusScope.of(context).requestFocus(nodeFirst);
      });
      EasyLoading.dismiss();
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Botão de voltar desativado nesta página')));
        return false;
      },
      child: Scaffold(
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
                /*Text(
                  'Seção: $secaoText BIPADOS: ${bips.length}',
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),*/
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
