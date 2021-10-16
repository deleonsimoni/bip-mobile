import 'package:bip/components/alerta.comp.dart';
import 'package:bip/pages/homePage.dart';
import 'package:bip/services/login.api.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final ctrlLogin = TextEditingController();
  final ctrlSenha = TextEditingController();
  final formKey = GlobalKey<FormState>();

  @override
  void initState() {
    _getThingsOnStartup();
    super.initState();
  }

  _getThingsOnStartup() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String token = prefs.get('tk');
    if (token != null) {
      Navigator.push(
          context, MaterialPageRoute(builder: (context) => HomePage()));
    }
  }

  String validaLogin(String texto) {
    if (texto.isEmpty) {
      return "Digite o Login";
    }
    return null;
  }

  String validaSenha(String texto) {
    if (texto.isEmpty) {
      return "Digite a Senha";
    }
    return null;
  }

  Future<void> clickLogin(BuildContext context) async {
    bool formValid = formKey.currentState.validate();

    if (!formValid) {
      return;
    }

    var usuario = await LoginApi.login(ctrlLogin.text, ctrlSenha.text);

    if (usuario != null) {
      navegaHomePage(context);
    } else {
      alerta(context, "Login Inválido", "Login");
    }
  }

  void navegaHomePage(BuildContext context) {
    Navigator.push(
        context, MaterialPageRoute(builder: (context) => HomePage()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Padding(
        padding: EdgeInsets.all(10),
        child: Form(
          key: formKey,
          child: Center(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextFormField(
                  autofocus: true,
                  keyboardType: TextInputType.emailAddress,
                  style: new TextStyle(color: Colors.white),
                  controller: ctrlLogin,
                  validator: validaLogin,
                  decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(color: Colors.white)),
                ),
                Divider(),
                TextFormField(
                  autofocus: true,
                  obscureText: true,
                  keyboardType: TextInputType.text,
                  controller: ctrlSenha,
                  validator: validaSenha,
                  style: new TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                      labelText: "Senha",
                      labelStyle: TextStyle(color: Colors.white)),
                ),
                Divider(),
                ButtonTheme(
                    height: 60.0,
                    child: ElevatedButton(
                        onPressed: () {
                          clickLogin(context);
                        },
                        child: Text(
                          "Entrar",
                          style: TextStyle(color: Colors.white),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Colors.red, // background
                          onPrimary: Colors.white, // foreground
                        )))
              ],
            ),
          ),
        ),
      ),
    );
  }
}
