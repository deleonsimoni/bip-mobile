import 'package:bip/models/bip.dart';
import 'package:bip/models/db/secao.dart';
import 'package:bip/models/inventarioList.dart';
import 'package:bip/pages/bipPage.dart';
import 'package:bip/pages/secaoInicioEFimPage.dart';
import 'package:bip/pages/secaoPage.dart';
import 'package:bip/services/databaseHandler.dart';
import 'package:bip/services/inventario.api.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DetalheInventariosPage extends StatefulWidget {
  InventarioList inventario;
  List<String> itensClient;

  DetalheInventariosPage(this.inventario, this.itensClient);

  @override
  State<StatefulWidget> createState() {
    return _DetalheInventariosPageState(this.inventario, this.itensClient);
  }
}

class _DetalheInventariosPageState extends State<DetalheInventariosPage> {
  InventarioList inventario;
  List<String> itensClient;

  _DetalheInventariosPageState(this.inventario, this.itensClient);

  List<Secao> listaSecoes = new List<Secao>();

  Secao secaoSelecionada;
  DatabaseHandler handler;

  @override
  void initState() {
    _getSecoes(inventario);
    super.initState();
  }

  _cadastrarSecaoInicioEFim(inventario, itensClient) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => SecaoInicioEFimPage(inventario, itensClient)));
  }

  void _getSecoes(inventario) async {
    EasyLoading.show(status: 'Listando Seções...');
    this.handler = DatabaseHandler();
    var secoes = await this.handler.getSecoes(inventario.sId);
    EasyLoading.dismiss();
    setState(() {
      listaSecoes = secoes;
    });
    if (listaSecoes == null || listaSecoes.length == 0) {
      _cadastrarSecaoInicioEFim(this.inventario, this.itensClient);
    }
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

  _returnIcon(secao) {
    if (secao.status == 0) {
      return Icon(Icons.pending_actions);
    } else if (secao.status == 1) {
      return Icon(Icons.signal_wifi_off_rounded);
    } else {
      return Icon(Icons.check);
    }
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
                          builder: (context) =>
                              SecaoPage(inventario, itensClient)),
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
                Text(
                    listaSecoes.length > 0 ? "Seções" : "Nenhuma seção bipada"),
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
                          leading: _returnIcon(listaSecoes[index]),
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
              ButtonTheme(
                height: 60.0,
                child: ElevatedButton(
                  onPressed: () {
                    _showOptionsSyncronize();
                  },
                  child: Text(
                    "Sincronizar com Servidor",
                    style: TextStyle(color: Colors.red),
                  ),
                  style: ElevatedButton.styleFrom(
                    minimumSize: Size(double.infinity, 30),

                    primary: Colors.yellow.shade400, // background
                    onPrimary: Colors.red, // foreground
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50)),
                  ),
                ),
              ),
            ],
          ),
        ));
  }

  _dismissDialog() {
    Navigator.pop(context);
  }

  _sincronizarSecoes() async {
    try {
      EasyLoading.show(status: 'Sincronizando...');
      SharedPreferences prefs = await SharedPreferences.getInstance();

      this.handler = DatabaseHandler();
      List<Bip> bips = [];
      List<Secao> secoes =
          await this.handler.getSecoesParaSincronizar(inventario.sId);

      for (final secao in secoes) {
        bips = await this.handler.getBipsSecao(secao.id);
        var request = {
          'inventory': inventario.sId,
          'section': secao.idSecao,
          'bip': bips
        };
        await InventarioApi.sincronizarSecao(request, prefs.get('tk'))
            .then((response) async {
          await this.handler.updateStatusSecao(secao.id, 2);
        });
      }
      EasyLoading.showSuccess('Dados Sincronizados Com Sucesso!');
      _dismissDialog();
      _getSecoes(inventario);
    } on Exception catch (e) {
      _dismissDialog();
      EasyLoading.showError(e.toString());
    }
  }

  _showOptionsSyncronize() {
    showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Sincronizar'),
            content: Text(
                'Está com internet e deseja enviar os dados para o servidor?'),
            actions: <Widget>[
              TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () async {
                  _sincronizarSecoes();
                },
                child: Text('Sim'),
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
                child: Text('Não'),
              )
            ],
          );
        });
  }

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
              /*TextButton(
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.all(16.0),
                  primary: Colors.blue,
                  textStyle: const TextStyle(fontSize: 20),
                ),
                onPressed: () {
                  _syncronizeServer(inventario, secaoSelecionada.idSecao);
                },
                child: Text('Enviar Seção'),
              ),*/
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
                        builder: (context) => BipPage(
                            inventario,
                            secaoSelecionada.id,
                            secaoSelecionada.idSecao,
                            itensClient,
                            false)),
                  );
                },
                child: secaoSelecionada.status == 0
                    ? Text('Abrir Seção')
                    : Text('Reabrir Seção'),
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
