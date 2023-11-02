import 'dart:async';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:flutter_cube/flutter_cube.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:nakuja_ui/websocket.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'map.dart';

typedef OnMessageCallback = void Function(List<MqttReceivedMessage> event);

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late MqttServerClient client;
  LatLng pinpointLocation = LatLng(0, 0);
  List<ChartData> chartDataAx = [];
  List<ChartData> chartDataAy = [];
  List<ChartData> chartDataAz = [];
  List<ChartData> chartDataVelocity = [];
  List<ChartData> chartDataAGL= [];
  double altitude = 0.0;
  double latitude = 0.0;
  double longitude = 0.0;
  double AGL = 0.0;
  double gx = 0.0;
  double gy = 0.0;
  double gz = 0.0;
  double rotationX = 0.0;
  double rotationY = 0.0;
  double rotationZ = 0.0;

  Timer? _timer;

  @override
  void initState() {
    super.initState();

    _timer = Timer.periodic(Duration(seconds: 1), (Timer timer) {
      setState(() {
        DateTime now = DateTime.now();
      });
    });

  }
  @override
  void dispose() {
    _timer?.cancel(); // Cancel the timer when the widget is disposed
    super.dispose();
  }


  Future<void> writeToStream(String data) async {
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/mqtt_data.txt');

    // Get the current timestamp
    final timestamp = DateTime.now();

    // Create a stream controller
    final controller = StreamController<String>.broadcast();

    // Open the file in append mode
    var sink = file.openWrite(mode: FileMode.append);

    // Listen for data on the stream
    controller.stream.listen((String data) {
      sink.write('$timestamp: $data\n'); // Add timestamp to the data
    });
    // Add data to the stream
    controller.sink.add(data);
    // Clean up resources
    controller.close();
    await sink.flush();
    await sink.close();
  }


  void _onMessage(List<MqttReceivedMessage> event) {
    final MqttPublishMessage message = event[0].payload;
    final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
    writeToStream(payload);
    final trimmedData = payload.substring(1);
    final values = trimmedData.split(',');

    final timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();

    setState(() {
      // Add data to respective lists
      chartDataAx.add(ChartData(timestamp, double.parse(values[0])));
      chartDataAy.add(ChartData(timestamp, double.parse(values[1])));
      chartDataAz.add(ChartData(timestamp, double.parse(values[2])));
      chartDataVelocity.add(ChartData(timestamp, double.parse(values[8])));
      chartDataAGL.add(ChartData(timestamp, double.parse(values[6])));

      if (chartDataAx.length > 10) {
        chartDataAx.removeAt(0);
        chartDataAy.removeAt(0);
        chartDataAz.removeAt(0);
      }

      if (chartDataVelocity.length > 10) {
        chartDataVelocity.removeAt(0);
      }

      if (chartDataAGL.length > 10) {
        chartDataAGL.removeAt(0);
      }
      // Update altitude, latitude, and longitude
      altitude = double.parse(values[10]);
      latitude = double.parse(values[11]);
      longitude = double.parse(values[12]);
      AGL = double.parse(values[6]);
      pinpointLocation = LatLng(latitude, longitude);

      //update rocket position
      gx = double.parse(values[3]);
      gy = double.parse(values[4]);
      gz = double.parse(values[5]);
      rotationX = gx;
      rotationY = gy;
      rotationZ = gz;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Nakuja"),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              ElevatedButton(onPressed: () {
                openDialog(context,_onMessage);
              },
                  child: Text("Connect to Websocket")
              ),
              Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text("T launch")),
                      Expanded(
                          child: Text("State")),
                      Expanded(
                          child: Text('AGL: ${AGL.toString()}')),
                      Expanded(
                        child: Text('Altitude: ${altitude.toString()}'),
                      ),
                      Expanded(
                        child: Text('Latitude: ${latitude.toString()}'),
                      ),
                      Expanded(
                        child:Text('longitude: ${longitude.toString()}'),
                      ),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            dynamic result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapLocation(pinpointLocation: pinpointLocation),
                                )
                            );
                            setState(() {
                            });
                          },
                          icon: Icon(
                            Icons.edit_location,
                            color: Colors.grey[300],
                          ),
                          label: Text("Map ",
                            style: TextStyle(
                                color: Colors.grey[300]),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: 250,
                      child: Row(
                        children: <Widget>[
                          Expanded(
                              child: Transform(
                                transform: Matrix4.identity()
                                ..rotateX(rotationX)
                                ..rotateY(rotationY)
                                ..rotateZ(rotationZ),
                                child: Cube(onSceneCreated: (Scene scene) {
                                scene.world.add(Object(
                            fileName: 'assets/images/fiberglass assembly_v3.obj',
                            scale: Vector3(8.0, 8.0, 8.0),
                                ));
                              },
                            ),
                          ),
                          ),
                           Expanded(child: Text("Streaming")),
                        ],
                      ),
                    ),
                  ],
                ),
                  Column(
                  children: <Widget>[
                    Text("Telemetry"),
                    // SizedBox(height: 10),
                  ],
                ),
              Row(
                children:<Widget> [
                  Expanded(child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      intervalType: DateTimeIntervalType.seconds,
                      dateFormat: DateFormat('HH:mm:ss'),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: 'AGL(m)',
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.top,),
                    series: <LineSeries<ChartData, DateTime>>[
                      LineSeries<ChartData, DateTime>(
                        color: Colors.purple,
                        legendItemText: 'AGL',
                        dataSource: chartDataAGL,
                        xValueMapper: (ChartData data, _) => DateTime.fromMillisecondsSinceEpoch(data.x.toInt()),
                        yValueMapper: (ChartData data, _) => data.y,
                      ),
                    ],
                  ),
                  ),
                  Expanded(child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      intervalType: DateTimeIntervalType.seconds,
                      dateFormat: DateFormat('HH:mm:ss'),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: 'Velocity (m/s)',
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.top,),
                    series: <LineSeries<ChartData, DateTime>>[

                      LineSeries<ChartData, DateTime>(
                        color: Colors.blueGrey,
                        legendItemText: 'Velocity',
                        dataSource: chartDataVelocity,
                        xValueMapper: (ChartData data, _) => DateTime.fromMillisecondsSinceEpoch(data.x.toInt()),
                        yValueMapper: (ChartData data, _) => data.y,
                      ),
                    ],
                  ),
                  ),
                  Expanded(child: SfCartesianChart(
                    primaryXAxis: DateTimeAxis(
                      intervalType: DateTimeIntervalType.seconds,
                      dateFormat: DateFormat('HH:mm:ss'),
                    ),
                    primaryYAxis: NumericAxis(
                      title: AxisTitle(
                        text: 'Acceleration(m/s2',
                        textStyle: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    legend: Legend(
                      isVisible: true,
                      position: LegendPosition.top,// Set to true to make the legend visible
                    ),
                    series: <LineSeries<ChartData, DateTime>>[
                      LineSeries<ChartData, DateTime>(
                        color: Colors.blue,
                        legendItemText: 'ax',
                        dataSource: chartDataAx,
                        xValueMapper: (ChartData data, _) => DateTime.fromMillisecondsSinceEpoch(data.x.toInt()),
                        yValueMapper: (ChartData data, _) => data.y,
                      ),
                      LineSeries<ChartData, DateTime>(
                        color: Colors.green,
                        legendItemText: 'ay',
                        dataSource: chartDataAy,
                        xValueMapper: (ChartData data, _) => DateTime.fromMillisecondsSinceEpoch(data.x.toInt()),
                        yValueMapper: (ChartData data, _) => data.y,
                      ),
                      LineSeries<ChartData, DateTime>(
                        color: Colors.red,
                        legendItemText: 'az',
                        dataSource: chartDataAz,
                        xValueMapper: (ChartData data, _) => DateTime.fromMillisecondsSinceEpoch(data.x.toInt()),
                        yValueMapper: (ChartData data, _) => data.y,
                      ),
                    ],
                  ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class ChartData {
  final double x;
  final double y;

  ChartData(this.x, this.y);
}
