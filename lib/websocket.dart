import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'dart:async';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'home.dart';

Future<void> openDialog(BuildContext context, OnMessageCallback onMessage) async {
  TextEditingController serverIdController = TextEditingController();

  await showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text("Connect to the server"),
        content: TextField(
          controller: serverIdController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(hintText: 'Enter the server ID'),
        ),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(Radius.circular(2))),
        actions: [
          TextButton(
            onPressed: () async {
              // String port = portController.text;
              String serverId = serverIdController.text; // Get the server ID from the controller
              await connectToMqtt(serverId, onMessage );
              submit(context);
            },
            child: Text('Submit'),
          ),
        ],
      );
    },
  );
}

void submit(BuildContext context) {
  Navigator.of(context).pop();
}

Future<void> connectToMqtt(String serverId,OnMessageCallback onMessage) async {

  final MqttServerClient client = MqttServerClient.withPort(serverId, 'flutter_client', 1883); // Use the serverId here instead of IP
  client.logging(on: true);
  client.keepAlivePeriod = 20;
  client.onDisconnected = () {
    print('Disconnected');
  };

  final MqttConnectMessage connMess = MqttConnectMessage()
      .withClientIdentifier('flutter_client')
      .startClean()
      .keepAliveFor(20)
      .withWillTopic('willtopic')
      .withWillMessage('Will message')
      .withWillQos(MqttQos.atLeastOnce);
  client.connectionMessage = connMess;
  try {
    await client.connect(serverId, '');
    print('Connected');
    // Subscribe to a specific topic
    client.subscribe("sensor_data_topic", MqttQos.atMostOnce);
    client.updates?.listen(onMessage);

  } catch (e) {
    print('Exception: $e');
    client.disconnect();
  }
}

