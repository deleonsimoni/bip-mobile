import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

alerta(BuildContext context, String msg, String title) {
  showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(title),
          content: Text(msg),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text("OK"),
            )
          ],
        );
      });
}
