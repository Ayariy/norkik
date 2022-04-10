import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:norkik_app/models/qrscan_model.dart';

class MapaPage extends StatefulWidget {
  const MapaPage({Key? key}) : super(key: key);

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  MapType mapType = MapType.normal;
  Completer<GoogleMapController> _controller = Completer();

  @override
  Widget build(BuildContext context) {
    final QrScan scan = ModalRoute.of(context)!.settings.arguments as QrScan;
    final CameraPosition puntoInicial =
        CameraPosition(target: scan.getLatLng(), zoom: 17, tilt: 50);

    //Marcadores

    Set<Marker> markers = Set<Marker>();
    markers.add(
        Marker(markerId: MarkerId('geo-location'), position: scan.getLatLng()));
    return Scaffold(
      appBar: AppBar(
        title: Text('Mapas'),
        actions: [
          IconButton(
              onPressed: () async {
                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(CameraUpdate.newCameraPosition(
                    CameraPosition(
                        target: scan.getLatLng(), zoom: 17, tilt: 50)));
              },
              icon: Icon(Icons.location_on))
        ],
      ),
      body: GoogleMap(
        markers: markers,
        mapType: mapType,
        initialCameraPosition: puntoInicial,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (mapType == MapType.normal) {
            mapType = MapType.satellite;
          } else {
            mapType = MapType.normal;
          }
          setState(() {});
        },
        child: Icon(Icons.layers),
      ),
    );
  }
}
