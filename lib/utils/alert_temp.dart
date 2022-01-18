import 'package:flutter/material.dart';

getAlert(BuildContext context, String title, String contenido) {
  return showDialog(
      useSafeArea: false,
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          contentPadding: EdgeInsets.fromLTRB(24, 20, 24, 0),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text(title),
          content: Text(contenido),
          actions: [
            TextButton(
                onPressed: () {
                  Navigator.pop(dialogContext);
                },
                child: Text('Aceptar'))
          ],
        );
      });
}
