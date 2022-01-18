import 'package:flutter/material.dart';

class HorarioPage extends StatefulWidget {
  HorarioPage({Key? key}) : super(key: key);

  @override
  State<HorarioPage> createState() => _HorarioPageState();
}

class _HorarioPageState extends State<HorarioPage> {
  List<List<bool>> matrizBool =
      List.generate(24, (index) => List.generate(7, (index) => false));
  int x = 0;
  int y = 0;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.only(top: 10),
        child: Column(
          children: [
            Row(
              children: [
                SizedBox(
                  width: 18,
                ),
                Container(
                  alignment: Alignment.center,
                  padding: EdgeInsets.zero,
                  margin: EdgeInsets.zero,
                  width: 62,
                  child: Text('Lun'),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.zero,
                  width: 62,
                  child: Text('Mar'),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.zero,
                  width: 62,
                  child: Text('Mie'),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.zero,
                  width: 62,
                  child: Text('Jue'),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.zero,
                  width: 62,
                  child: Text('Vie'),
                ),
                Container(
                  alignment: Alignment.center,
                  margin: EdgeInsets.zero,
                  width: 62,
                  child: Text('Sab'),
                )
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: Table(
                  columnWidths: {0: FractionColumnWidth(0.05)},
                  border: TableBorder(
                      verticalInside: BorderSide(width: 0.8),
                      horizontalInside: BorderSide(width: 0.5)),
                  children: _getTableRowList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _getListRow(int indexRow) {
    List<Widget> widet = [];
    for (var i = 0; i < 7; i++) {
      widet.add(
        GestureDetector(
          onTap: () {
            if (x == indexRow && y == i) {
              x = 0;
              y = 0;
            } else {
              matrizBool[x][y] = false;
              x = indexRow;
              y = i;
            }
            setState(() {
              matrizBool[indexRow][i] = true;
            });
          },
          child: Container(
              decoration: BoxDecoration(),
              height: 60,
              child: i == 0
                  ? Text(indexRow.toString())
                  : matrizBool[indexRow][i]
                      ? Container(
                          margin: EdgeInsets.all(1),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(3),
                            color: Theme.of(context).primaryColor,
                          ),
                          height: 60,
                          child: Icon(
                            Icons.add,
                            size: 40,
                            color:
                                Theme.of(context).appBarTheme.foregroundColor,
                          ),
                        )
                      : SizedBox()),
        ),
      );
    }

    return widet;
  }

  List<TableRow> _getTableRowList() {
    List<TableRow> widetRow = [];
    for (var i = 0; i <= 23; i++) {
      widetRow.add(TableRow(children: _getListRow(i)));
    }
    return widetRow;
  }
}
