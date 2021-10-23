import 'package:bip/models/db/secao.dart';
import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/bipPage.dart';
import 'package:bip/pages/secaoPage.dart';
import 'package:bip/services/databaseHandler.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

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

  List<Secao> listaSecoes = new List<Secao>();

  Secao secaoSelecionada;
  DatabaseHandler handler;

  @override
  void initState() {
    _getSecoes(inventario).then((value) => setState(() {
          EasyLoading.dismiss();
          listaSecoes = value;
        }));
    super.initState();
  }

  Future<List<Secao>> _getSecoes(inventario) async {
    EasyLoading.show(status: 'Listando Seções...');
    this.handler = DatabaseHandler();
    return await this.handler.getSecoes(inventario.sId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          //leading: Text('B.I.P'),
          title: Text('${inventario.client.name}'),
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
                'Escolha a opção:',
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
                    "Nova Seção",
                    style: TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 60),

                    primary: Colors.red.shade700, // background
                    onPrimary: Colors.white, // foreground
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
              Divider(
                height: 20,
                thickness: 5,
                indent: 20,
                endIndent: 20,
                color: Colors.white,
              ),
              Row(children: <Widget>[
                Expanded(child: Divider()),
                Text(listaSecoes.length > 0
                    ? "Seções já bipadas"
                    : "Nenhuma seção bipada"),
                Expanded(child: Divider()),
              ]),
              Container(
                  height: 190.0,
                  child: Scrollbar(
                      child: ListView.builder(
                    itemCount: listaSecoes.length,
                    itemBuilder: (context, index) {
                      return ClipRRect(
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(32),
                          bottomLeft: Radius.circular(32),
                        ),
                        child: ListTile(
                          leading: listaSecoes[index].status == 1
                              ? Icon(Icons.signal_wifi_off_rounded)
                              : Icon(Icons.done_outline_sharp),
                          title: Text(listaSecoes[index].idSecao),
                          selected: false,
                          trailing: Wrap(
                            spacing: 12, // space between two icons
                            children: <Widget>[
                              Text('BIPs: ' +
                                  listaSecoes[index].qtdBips.toString())
                            ],
                          ),
                          onTap: () {
                            _showOptionsDialog(listaSecoes[index]);
                          },
                          onLongPress: () {
                            _showOptionsDialogDelete(listaSecoes[index]);
                          },
                        ),
                      );
                    },
                  ))),
              Divider(),
            ],
          ),
        ));
  }

  _dismissDialog() {
    Navigator.pop(context);
  }

  void _syncronizeServer(inventario, secao) {}

  void _showOptionsDialogDelete(secao) {
    this.secaoSelecionada = secao;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('${secaoSelecionada.idSecao}'),
            content: Text('Deseja excluir esta seção?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _dismissDialog();
                },
                child: Text('Não'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  EasyLoading.show(status: 'Aguarde...');
                  await this.handler.deleteBip(secaoSelecionada.id);
                  await this.handler.deleteSecao(secaoSelecionada.id);
                  _dismissDialog();
                  initState();
                  EasyLoading.dismiss();
                  _dismissDialog();
                },
                child: Text('Sim'),
              )
            ],
          );
        });
  }

  void _showOptionsDialog(secao) {
    this.secaoSelecionada = secao;
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('${secaoSelecionada.idSecao}'),
            content: Text('O que deseja fazer?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _syncronizeServer(inventario, secaoSelecionada.idSecao);
                },
                child: Text('Enviar Seção'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _dismissDialog();
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => BipPage(inventario,
                            secaoSelecionada.id, secaoSelecionada.idSecao)),
                  );
                },
                child: Text('Reabrir Seção'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _dismissDialog();
                },
                child: Text('Voltar'),
              )
            ],
          );
        });
  }
}
