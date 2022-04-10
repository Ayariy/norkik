import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'package:norkik_app/models/qrscan_model.dart';
import 'package:norkik_app/providers/storage_shared.dart';
import 'package:norkik_app/utils/url_launcher.dart';
import 'package:uuid/uuid.dart';

class QRPage extends StatefulWidget {
  QRPage({Key? key}) : super(key: key);

  @override
  State<QRPage> createState() => _QRPageState();
}

class _QRPageState extends State<QRPage> {
  StorageShared storageShared = StorageShared();

  List<QrScan> listQrScan = [];

  int indexPage = 0;

  bool isLoading = false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _getListQrScan();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historial QR'),
        actions: [
          IconButton(
              onPressed: () {
                storageShared.eliminarQrScanStorageList();
                setState(() {
                  _getListQrScan();
                });
              },
              icon: Icon(Icons.delete_forever))
        ],
      ),
      body: isLoading
          ? Center(
              child: CircularProgressIndicator(),
            )
          : indexPage == 0
              ? mapasPage()
              : direccionesPage(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: indexPage,
        onTap: (valuePage) {
          setState(() {
            indexPage = valuePage;
          });
        },
        elevation: 0,
        items: [
          BottomNavigationBarItem(
              label: 'Mapa',
              icon: Icon(
                Icons.map,
              )),
          BottomNavigationBarItem(
              label: 'Direcciones', icon: Icon(Icons.compass_calibration))
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.filter_center_focus),
        onPressed: () async {
          setState(() {
            isLoading = true;
          });
          String barcodeScanRes = await FlutterBarcodeScanner.scanBarcode(
              '#3D8BEF', 'Cancelar', false, ScanMode.QR);
          // barcodeScanRes = 'https://www.youtube.com/';
          if (barcodeScanRes == '-1') {
            setState(() {
              _getListQrScan();
              isLoading = false;
            });
            return;
          }
          if (barcodeScanRes.contains('geo') ||
              barcodeScanRes.contains('http')) {
            String idQrScan = Uuid().v1();
            QrScan scan = QrScan(
                idScan: idQrScan,
                tipo: barcodeScanRes.contains('geo') ? 'geo' : 'http',
                valor: barcodeScanRes);
            listQrScan.add(scan);
            storageShared.agregarQrScanStorageList(listQrScan);
            launchURL(context, scan);
          }
          setState(() {
            _getListQrScan();
            isLoading = false;
          });
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Widget mapasPage() {
    List<QrScan> listQrMapas =
        listQrScan.where((element) => element.tipo == 'geo').toList();
    return listQrMapas.isEmpty
        ? Center(
            child: Text('No hay registros por el momento'),
          )
        : ListView.builder(
            itemCount: listQrMapas.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: UniqueKey(),
                background: Container(
                  color: Colors.red[400],
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red[400],
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) {
                  listQrScan.removeWhere(
                      (element) => listQrMapas[index].idScan == element.idScan);
                  storageShared.agregarQrScanStorageList(listQrScan);
                  setState(() {
                    _getListQrScan();
                  });
                },
                child: ListTile(
                  leading: Icon(Icons.map),
                  title: Text('Latitud: ' +
                      listQrMapas[index].getLatLng().latitude.toString() +
                      ' Longitud: ' +
                      listQrMapas[index].getLatLng().longitude.toString()),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => launchURL(context, listQrMapas[index]),
                ),
              );
            },
          );
  }

  Widget direccionesPage() {
    List<QrScan> listQrWeb =
        listQrScan.where((element) => element.tipo == 'http').toList();
    return listQrWeb.isEmpty
        ? Center(
            child: Text('No hay registros por el momento'),
          )
        : ListView.builder(
            itemCount: listQrWeb.length,
            itemBuilder: (context, index) {
              return Dismissible(
                key: UniqueKey(),
                background: Container(
                  color: Colors.red[400],
                  alignment: Alignment.centerLeft,
                  padding: EdgeInsets.only(left: 10),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                secondaryBackground: Container(
                  color: Colors.red[400],
                  alignment: Alignment.centerRight,
                  padding: EdgeInsets.only(right: 10),
                  child: Icon(
                    Icons.delete_outline_rounded,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) {
                  listQrScan.removeWhere(
                      (element) => listQrWeb[index].idScan == element.idScan);
                  storageShared.agregarQrScanStorageList(listQrScan);
                  setState(() {
                    _getListQrScan();
                  });
                },
                child: ListTile(
                  leading: Icon(Icons.web),
                  title: Text(listQrWeb[index].valor),
                  trailing: Icon(Icons.arrow_forward_ios_rounded),
                  onTap: () => launchURL(context, listQrWeb[index]),
                ),
              );
            },
          );
  }

  void _getListQrScan() async {
    isLoading = true;
    listQrScan = await storageShared.obtenerQrScanStorageList();
    setState(() {
      isLoading = false;
    });
  }
}
