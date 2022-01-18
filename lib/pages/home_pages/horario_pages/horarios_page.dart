import 'package:flutter/material.dart';

class HorariosPage extends StatelessWidget {
  HorariosPage({Key? key}) : super(key: key);

  bool isLoading = false;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Horarios de clase creados'),
        ),
        body: isLoading
            ? Center(
                child: CircularProgressIndicator(),
              )
            : ListView.builder(
                itemCount: 3,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text('Horario' + index.toString()),
                  );
                }),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ));
  }
}
