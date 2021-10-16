import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/secaoPage.dart';
import 'package:flutter/material.dart';

class DetalheInventariosPage extends StatefulWidget {
  InventarioList inventario;

  DetalheInventariosPage(this.inventario);

  @override
  State<StatefulWidget> createState() {
    return _DetalheInventariosPageState(this.inventario);
  }
}

class _DetalheInventariosPageState extends State<DetalheInventariosPage> {
  InventarioList inventario;
  _DetalheInventariosPageState(this.inventario);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //leading: Text('B.I.P'),
          title: Text('Inventário'),
          actions: [
            Icon(Icons.ac_unit),
          ],
        ),
        body: detalheInventario());
  }

  detalheInventario() {
    return Padding(
        padding: EdgeInsets.all(10),
        child: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Inventário: ${inventario.client.name}. Escolha a opção?',
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Divider(),
              ButtonTheme(
                height: 60.0,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => SecaoPage(inventario)),
                    );
                  },
                  child: Text(
                    "Abrir Seção",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // background
                    onPrimary: Colors.white, // foreground
                  ),
                ),
              ),
              Divider(),
              ButtonTheme(
                height: 60.0,
                child: ElevatedButton(
                  onPressed: () {
                    //reabrir seção
                  },
                  child: Text(
                    "Reabrir Seção",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.red, // background
                    onPrimary: Colors.white, // foreground
                  ),
                ),
              ),
              Divider(),
            ],
          ),
        ));
  }
}
