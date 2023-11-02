import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'package:nakuja_ui/map.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:nakuja_ui/websocket.dart';
import 'dart:async';
import 'dart:math' as math;
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:intl/intl.dart'; // For date formatting
import 'package:mqtt_client/mqtt_browser_client.dart';


class HomeScreen extends StatefulWidget {

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  List<SensorData> sensor1Data = [];
  List<SensorData> sensor2Data = [];
  List<SensorData> sensor3Data = [];
  List<SensorData> sensor7Data = [];
  List<SensorData> sensor9Data = [];
  Timer? _timer;

  void onDataReceived(String topic, String payload) {
    List<List<dynamic>> rowsAsListOfValues = const CsvToListConverter().convert(payload);

    for (int i = 0; i < rowsAsListOfValues.length; i++) {
      String sensorId = rowsAsListOfValues[i][0];
      double value = double.parse(rowsAsListOfValues[i][1].toString());
      DateTime timestamp = DateTime.now(); // Get current time

      SensorData newData = SensorData(sensorId, value, timestamp);

      setState(() {
        if (i == 0 || i == 1 || i == 2) {
          sensor1Data.add(newData);
        } else if (i == 6) {
          sensor7Data.add(newData);
        } else if (i == 8) {
          sensor9Data.add(newData);
        }
      });
    }
  }

  @override
  void initState() {

    super.initState();
    // Set up a timer to update the chart every second
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
                openDialog(context);
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
                          child: Text("Altitude")),
                      Expanded(
                          child: Text("AGL")),
                      Expanded(
                          child: Text("T launch")),
                      Expanded(
                          child: Text("Location")),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () async {
                            dynamic result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => MapLocation()
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
                  Row(
                    children: <Widget>[
                      Expanded(
                          child: Text("REnder 3D")),
                      Expanded(
                          child: Text("Streaming")),
                    ],
                  ),
                ],
              ),
              Row(
                children:<Widget> [
                  Expanded(
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat.Hms(),
                        intervalType: DateTimeIntervalType.seconds,
                      ),
                      primaryYAxis: NumericAxis(),
                      series: <ChartSeries>[
                        LineSeries<SensorData, DateTime>(
                          dataSource: sensor1Data,
                          xValueMapper: (SensorData data, _) => data.timestamp,
                          yValueMapper: (SensorData data, _) => data.value,
                          name: 'Sensor 1',
                        ),
                        LineSeries<SensorData, DateTime>(
                          dataSource: sensor2Data,
                          xValueMapper: (SensorData data, _) => data.timestamp,
                          yValueMapper: (SensorData data, _) => data.value,
                          name: 'Sensor 2',
                        ),
                        LineSeries<SensorData, DateTime>(
                          dataSource: sensor3Data,
                          xValueMapper: (SensorData data, _) => data.timestamp,
                          yValueMapper: (SensorData data, _) => data.value,
                          name: 'Sensor 3',
                        ),
                      ],
                    ),
                  ),

                  // Widget to display graph for Sensor 7
                  Expanded(
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat.Hms(),
                        intervalType: DateTimeIntervalType.seconds,
                      ),
                      primaryYAxis: NumericAxis(),
                      series: <ChartSeries>[
                        LineSeries<SensorData, DateTime>(
                          dataSource: sensor7Data,
                          xValueMapper: (SensorData data, _) => data.timestamp,
                          yValueMapper: (SensorData data, _) => data.value,
                          name: 'Sensor 7',
                        ),
                      ],
                    ),
                  ),

                  // Widget to display graph for Sensor 9
                  Expanded(
                    child: SfCartesianChart(
                      primaryXAxis: DateTimeAxis(
                        dateFormat: DateFormat.Hms(),
                        intervalType: DateTimeIntervalType.seconds,
                      ),
                      primaryYAxis: NumericAxis(),
                      series: <ChartSeries>[
                        LineSeries<SensorData, DateTime>(
                          dataSource: sensor9Data,
                          xValueMapper: (SensorData data, _) => data.timestamp,
                          yValueMapper: (SensorData data, _) => data.value,
                          name: 'Sensor 9',
                        ),
                      ],
                    ),
                  ),

                ],
              ),
              Column(
                children: <Widget>[
                  Text("Telemetry"),
                  SizedBox(height: 20),
                  //   Row(
                  //     children: <Widget>[
                  //
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

}

class SensorData {
  final String sensorId;
  final double value;
  final DateTime timestamp;

  SensorData(this.sensorId, this.value, this.timestamp);
}
