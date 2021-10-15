import 'package:bip/pages/inventariosPage.dart';
import 'package:bip/pages/loginPage.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BipPage extends StatefulWidget {
  String inventario;

  BipPage(this.inventario);

  @override
  State<StatefulWidget> createState() {
    return _BipPageState(this.inventario);
  }
}

class _BipPageState extends State<BipPage> {
  String usuario = '';
  String inventario;
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
                        Icons.account_box,
                        size: 28.0,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.remove),
                      )),
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
                        Icons.account_box,
                        size: 28.0,
                      ),
                      suffixIcon: IconButton(
                        icon: Icon(Icons.remove),
                      )),
                ),
              ),
              Divider(),
              ButtonTheme(
                height: 200.0,
                child: ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    "Registrar",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
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
                    onPressed: () {},
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
}
