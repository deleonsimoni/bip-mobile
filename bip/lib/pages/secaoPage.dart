import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/bipPage.dart';
import 'package:bip/pages/loginPage.dart';
import 'package:bip/services/databaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SecaoPage extends StatefulWidget {
  InventarioList inventario;

  SecaoPage(this.inventario, this.itensClient);
  List<String> itensClient;

  @override
  State<StatefulWidget> createState() {
    return _SecaoPageState(this.inventario, this.itensClient);
  }
}

class _SecaoPageState extends State<SecaoPage> {
  String usuario = '';
  InventarioList inventario;
  DatabaseHandler handler;
  List<String> itensClient;
  bool showKeyboard = true;
  bool isPermitAvulse = false;

  final ctrlSecao = TextEditingController();

  _SecaoPageState(this.inventario, this.itensClient) {}

  Future<void> sair() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => LoginPage()));
  }

  _bipar() async {
    if (ctrlSecao.text == "" || ctrlSecao == null) {
      EasyLoading.showError('Digite a seção');
      return;
    }
    this.handler = DatabaseHandler();
    bool existSection =
        await this.handler.checkSectionExist(inventario.sId, ctrlSecao.text);

    if (existSection) {
      EasyLoading.showError('Seção já bipada por este dispositivo');
      return;
    }
    /* else {
      //check secao in server
      existSection
    }*/

    final idSecao =
        await this.handler.insertSecao(inventario.sId, ctrlSecao.text);

    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => BipPage(inventario, idSecao, ctrlSecao.text,
              this.itensClient, isPermitAvulse)),
    );
  }

  String validaSecao(String texto) {
    if (texto.isEmpty) {
      return "Escaneie a Seção";
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    Color getColor(Set<MaterialState> states) {
      const Set<MaterialState> interactiveStates = <MaterialState>{
        MaterialState.pressed,
        MaterialState.hovered,
        MaterialState.focused,
      };
      if (states.any(interactiveStates.contains)) {
        return Colors.blue;
      }
      return Colors.red;
    }

    return Scaffold(
      appBar: AppBar(
        //leading: Text('B.I.P'),
        title: Text('Seção'),
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
                'iventário ${inventario.client.name}.\n Escaneie a seção para iniciar',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(),
              Container(
                margin: EdgeInsets.only(left: 16.0),
                child: TextFormField(
                  autofocus: true,
                  controller: ctrlSecao,
                  showCursor: showKeyboard,
                  readOnly: showKeyboard,
                  validator: validaSecao,
                  onTap: () {
                    setState(() {
                      showKeyboard = false;
                    });
                  },
                  decoration: InputDecoration(
                      hintText: 'Seção',
                      filled: true,
                      prefixIcon: Icon(
                        Icons.account_box,
                        size: 28.0,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.remove),
                      )),
                ),
              ),
              Divider(),
              Text(
                'Seção para contagem avulsa?',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Checkbox(
                checkColor: Colors.white,
                fillColor: MaterialStateProperty.resolveWith(getColor),
                value: isPermitAvulse,
                onChanged: (bool value) {
                  setState(() {
                    isPermitAvulse = value;
                  });
                },
              ),
              ButtonTheme(
                height: 60.0,
                child: ElevatedButton(
                  onPressed: () {
                    _bipar();
                  },
                  child: Text(
                    "BIPAR",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // background
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
