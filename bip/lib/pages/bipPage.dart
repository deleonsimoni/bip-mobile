import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/inventariosPage.dart';
import 'package:bip/pages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BipPage extends StatefulWidget {
  InventarioList inventario;

  BipPage(this.inventario);

  @override
  State<StatefulWidget> createState() {
    return _BipPageState(this.inventario);
  }
}

class _BipPageState extends State<BipPage> {
  String usuario = '';
  InventarioList inventario;
  _BipPageState(this.inventario);

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
                  autofocus: true,
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
                  onPressed: () {},
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
            title: Text('Finalizar Seção'),
            content: Text(
                'Para finalizer a seção digite a quantidade de itens bipados'),
            actions: <Widget>[
              TextFormField(
                autofocus: true,
                decoration: InputDecoration(
                  hintText: 'Quantidade de itens bipados',
                  filled: true,
                  prefixIcon: Icon(
                    Icons.check_circle_outline_rounded,
                    size: 28.0,
                  ),
                ),
              ),
              TextButton(
                  onPressed: () {
                    _dismissDialog();
                  },
                  child: Text('Voltar')),
              TextButton(
                onPressed: () {
                  print('HelloWorld!');
                  _dismissDialog();
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
