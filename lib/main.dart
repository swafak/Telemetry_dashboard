import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:nakuja_ui/home.dart';
import 'package:nakuja_ui/map.dart';
import 'package:nakuja_ui/websocket.dart';


void main() => runApp(MaterialApp(

  // connectToMqtt(''); // Replace with your server ID

  debugShowCheckedModeBanner: false,
  initialRoute: '/home',
  routes: {
    // '/': (context) => LoadingScreen(),
    '/home': (context) => MyHomePage(),
    '/map': (context) => MapLocation(pinpointLocation: LatLng(0, 0),),
  },
));
