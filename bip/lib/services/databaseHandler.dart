import 'package:bip/models/itemsList.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

extension Ex on double {
  double toPrecision(int n) => double.parse(toStringAsFixed(n));
}

class DatabaseHandler {
  Future<Database> initializeDB() async {
    String path = await getDatabasesPath();
    return openDatabase(
      join(path, 'bip.db'),
      onCreate: (database, version) async {
        await database.execute(
          "CREATE TABLE itens(id INTEGER PRIMARY KEY AUTOINCREMENT, idInventario TEXT NOT NULL,refer text NOT NULL)",
        );
      },
      version: 1,
    );
  }

  Future<void> insertItem(List<ItemsList> itens) async {
    int total = itens[0].itens.length;
    int corrente = 0;
    double percent = 0;
    var idInventario = itens[0].sId;
    final Database db = await initializeDB();
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

  Future<bool> checkReferInBase(String idInventario, String refer) async {
    final Database db = await initializeDB();
    var res = await db.rawQuery(
        "SELECT * FROM itens WHERE idInventario = $idInventario AND refer = $refer");
    if (res.length != null) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> checkInventoryInBase(String idInventario) async {
    final Database db = await initializeDB();

    var res = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM itens WHERE idInventario = ?", [idInventario]));
    if (res != null && res > 0) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> deleteInventory(String id) async {
    final db = await initializeDB();
    await db.delete(
      'itens',
      where: "idInventario = ?",
      whereArgs: [id],
    );
  }
}
