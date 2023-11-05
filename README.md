# nakuja_ui

A new Flutter project.


## Requirements

- Flutter SDK (compatible with Dart 2.12.0 and above)
- MQTT server for data transmission
- MapTile server for map display
- Docker (optional, for running MapTile server in a containerized environment)

## Installation

1. **Flutter SDK**:

    You can download it from [here](https://flutter.dev/docs/get-started/install).

2. **Packages**:

   In your project directory, run the following command to install the required packages:

   ```
   flutter pub get
   ```

## Connecting to the Servers

### MQTT Server

To connect to the MQTT server, follow these steps:

1. **Run MQTT Server**:

   Make sure you have an MQTT server running. If not, you can install and run one on your local machine or use a remote server.

2. **Enter MQTT Server ID**:

   When you run the app, a dialogue box will prompt you to enter the MQTT server ID.

    - Enter the server's IP address.

3. **Connect to Websocket**:

   Click the "Connect to Websocket" button to establish a connection to the MQTT server.

### MapTile Server
If you're using a remote server,
To use a MapTile server, follow these steps:

1. **Run Dockerized MapTile Server (Optional)**:

   If you prefer to use Docker to run the MapTile server, follow these steps:

    - Install Docker: [Docker Installation Guide](https://docs.docker.com/get-docker/)
  
    - Run the MapTile server in a Docker container: In the directory containing the maptile server ,run the following command

      ```
      docker run --rm -it -v $(pwd):/data -p 8080:8080 maptiler/tileserver-gl --mbtiles osm-2020-02-10-v3.11_africa_kenya.mbtiles
      ```

2. **Configure MapTile URL**:

   In the `MapLocation` widget, update the `urlTemplate` property of `TileLayer` with the URL of your MapTile server.

## Usage

Once connected to the MQTT server, the app will start receiving data. The data will be displayed in various sections of the app:

- Telemetry Charts: Displays real-time telemetry data.
- 3D Model: Represents the rocket's position based on received sensor data.
- Map: Shows the location of the rocket on a map.

## Additional Notes

- Make sure your MQTT server is configured to send data to the topic `sensor_data_topic`.
- The app is designed to handle valid sensor data. Invalid data will be skipped.


## Acknowledgements

- [Flutter](https://flutter.dev/)
- [MQTT Client Package](https://pub.dev/packages/mqtt_client)
- [Flutter Map Package](https://pub.dev/packages/flutter_map)
- [Syncfusion Flutter Charts Package](https://pub.dev/packages/syncfusion_flutter_charts)


For any questions or assistance, please contact [Your Name](mailto:safakorane@gmail.com).

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
