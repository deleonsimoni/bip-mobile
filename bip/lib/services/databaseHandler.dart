import 'package:bip/models/db/secao.dart';
import 'package:bip/models/itemsList.dart';
import 'package:bip/services/FileUtils.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'dart:convert';

String tableInventory =
    "CREATE TABLE IF NOT EXISTS inventoryClient(id INTEGER PRIMARY KEY AUTOINCREMENT, idInventario TEXT NOT NULL) ";
String tableSecao =
    "CREATE TABLE IF NOT EXISTS secao(id INTEGER PRIMARY KEY AUTOINCREMENT, idInventario TEXT NOT NULL, idSecao text NOT NULL, status INTEGER NOT NULL)";
String tableItens =
    "CREATE TABLE IF NOT EXISTS bip(id INTEGER PRIMARY KEY AUTOINCREMENT, idInventario TEXT NOT NULL, idSecao int NOT NULL, bip TEXT NOT NULL, device TEXT NOT NULL, isFounded INTEGER NOT NULL,  FOREIGN KEY (idSecao) REFERENCES secao(id))";

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class DatabaseHandler {
  static Database _database;
  FileUtils fileUtils = new FileUtils();

  Future<Database> get database async {
    if (_database != null) return _database;

    // if _database is null we instantiate it
    _database = await initializeDB();
    return _database;
  }

  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'bipdb10.db'),
      onCreate: (database, version) async {
        await database.execute(tableInventory);
        await database.execute(tableSecao);
        await database.execute(tableItens);
      },
      version: 3,
    );
  }

  Future<void> insertInventory(String idInventory) async {
    final db = await database;

    await db.insert('inventoryClient', {'idInventario': idInventory});
  }

  Future<int> insertSecao(String idInventory, String idSecao) async {
    final db = await database;
    return await db.insert('secao',
        {'idInventario': idInventory, 'idSecao': idSecao, 'status': 0});
  }

  Future<void> insertBip(String idInventory, int idSecao, String bip,
      bool isFounded, String device) async {
    final db = await database;
    await db.insert('bip', {
      'bip': bip,
      'idInventario': idInventory,
      'idSecao': idSecao,
      'isFounded': isFounded,
      'device': device
    });
  }

  Future<void> updateStatusSecao(int idSecao, int status) async {
    final db = await database;
    await db.rawUpdate('''
    UPDATE secao 
    SET status = ?
    WHERE id = ?
    ''', [status, idSecao]);
  }

  Future<bool> checkSectionExist(String idInventario, String idSecao) async {
    final db = await database;

    var res = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM secao WHERE idInventario = ? AND idSecao = ?",
        [idInventario, idSecao]));
    if (res > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> insertItens(List<ItemsList> itens) async {
    int total = itens[0].itens.length;
    int corrente = 0;
    double percent = 0;
    var idInventario = itens[0].sId;
    final db = await database;
    EasyLoading.show(status: 'Instalando...');

    for (var item in itens[0].itens) {
      corrente++;
      percent = (corrente / total * 100);
      print('$corrente de $total');
      //EasyLoading.showProgress(percent.toPrecision(4), status: 'Instalando...');
      await db
          .insert('itens', {'idInventario': idInventario, 'refer': item.refer});
    }
  }

  Future<List<Secao>> getSecoes(String idInventario) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery(
        "SELECT s.*, count(b.id) bips FROM secao s " +
            "left JOIN bip b on s.id = b.idSecao " +
            "WHERE s.idInventario = '$idInventario' " +
            "GROUP BY s.idsecao ");
    return List.generate(maps.length, (i) {
      return Secao(
        id: maps[i]['id'],
        idInventario: maps[i]['idInventario'],
        idSecao: maps[i]['idSecao'],
        status: maps[i]['status'],
        qtdBips: maps[i]['bips'],
      );
    });
  }

  Future<List<String>> getItenClient(String idInventario) async {
    String arquivo = await fileUtils.read(idInventario);
    List<String> retorno = [];

    var refers = json.decode(arquivo);

    await Future.forEach(refers[0]['itens'], (v) async {
      retorno.add(v['refer']);
    });
    return retorno;
  }

  Future<bool> checkReferInBase(String idInventario, String refer) async {
    final db = await database;
    var res = await db.rawQuery(
        "SELECT COUNT(*) FROM itens WHERE idInventario = $idInventario AND refer = $refer");
    if (res.length != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkInventoryInBase(String idInventario) async {
    final db = await database;

    var res = await Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM inventoryClient WHERE idInventario = '$idInventario' "));
    if (res > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteInventory(String id) async {
    final db = await initializeDB();
    await db.delete(
      'inventoryClient',
      where: "idInventario = ?",
      whereArgs: [id],
    );
  }

  Future<void> deleteSecao(int idSecao) async {
    final db = await initializeDB();
    await db.delete(
      'secao',
      where: "id = ?",
      whereArgs: [idSecao],
    );
  }

  Future<void> deleteBip(int idSecao) async {
    final db = await initializeDB();
    await db.delete(
      'bip',
      where: "idSecao = ?",
      whereArgs: [idSecao],
    );
  }
}
