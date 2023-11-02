import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class MapLocation extends StatefulWidget {
  final LatLng pinpointLocation ;
  const MapLocation({Key? key, required this.pinpointLocation}) : super(key: key);

  @override
  State<MapLocation> createState() => _MapLocationState();
}

class _MapLocationState extends State<MapLocation> {
  @override
  Widget build(BuildContext context) {
    print("this is the latlong");
    print(widget.pinpointLocation);
    return Scaffold(
      appBar: AppBar(
        title: Text('Location'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),
      body: FlutterMap(
        options: MapOptions(
          // center: widget.pinpointLocation, // Set initial position
          center: LatLng(0.35462 ,37.58218),

          zoom: 13.0, // Set initial zoom level
        ),
        children: [
          TileLayer(
            urlTemplate: "http://192.168.100.4:8080/styles/basic-preview/{z}/{x}/{y}.png",
          ),
          MarkerLayer(
            markers: [
              Marker(
                width: 80.0,
                height: 80.0,
                point: LatLng(0.35462 ,37.58218),
                // point: widget.pinpointLocation, // Update with received coordinates
                builder: (ctx) => Container(
                  child: Icon(
                    Icons.location_on,
                    color: Colors.red,
                    size: 40.0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}


