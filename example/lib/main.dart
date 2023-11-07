import 'dart:async';

import 'package:ts_location/ts_location.dart';
import 'package:flutter/material.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String latitude = 'waiting...';
  String longitude = 'waiting...';
  String altitude = 'waiting...';
  String accuracy = 'waiting...';
  String bearing = 'waiting...';
  String speed = 'waiting...';
  String time = 'waiting...';

  // Add a subscription variable to hold the stream subscription
  late StreamSubscription<Location> _locationSubscription;

  @override
  void initState() {
    super.initState();
     WidgetsBinding.instance
        .addPostFrameCallback((_) => afterFirstLayout(context));
    // // Start the location service
    // BackgroundLocation.startLocationService(distanceFilter: 20);
   
  }
  Future<void>afterFirstLayout(BuildContext ctx) async{
      await BackgroundLocation.setAndroidNotification(
                      title: 'Background service is running',
                      message: 'Background location in progress',
                      icon: '@mipmap/ic_launcher',
                    );
            
                    await BackgroundLocation
                        .startLocationService(distanceFilter: 20);
 // Subscribe to the location updates stream
    _locationSubscription =
        BackgroundLocation.locationUpdates.listen((location) {
      setState(() {
        latitude = location.latitude.toString();
        longitude = location.longitude.toString();
        accuracy = location.accuracy.toString();
        altitude = location.altitude.toString();
        bearing = location.bearing.toString();
        speed = location.speed.toString();
        time = DateTime.fromMillisecondsSinceEpoch(location.time!.toInt())
            .toString();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text('Background Location Service'),
        ),
        body: Center(
          child: ListView(
            children: <Widget>[
              locationData('Latitude: ' + latitude),
              locationData('Longitude: ' + longitude),
              locationData('Altitude: ' + altitude),
              locationData('Accuracy: ' + accuracy),
              locationData('Bearing: ' + bearing),
              locationData('Speed: ' + speed),
              locationData('Time: ' + time),
              ElevatedButton(
                  onPressed: () async {
                  
                    // BackgroundLocation.getLocationUpdates((location) {
                    //   setState(() {
                    //     latitude = location.latitude.toString();
                    //     longitude = location.longitude.toString();
                    //     accuracy = location.accuracy.toString();
                    //     altitude = location.altitude.toString();
                    //     bearing = location.bearing.toString();
                    //     speed = location.speed.toString();
                    //     time = DateTime.fromMillisecondsSinceEpoch(
                    //             location.time!.toInt())
                    //         .toString();
                    //   });
                    //   print('''\n
                    //     Latitude:  $latitude
                    //     Longitude: $longitude
                    //     Altitude: $altitude
                    //     Accuracy: $accuracy
                    //     Bearing:  $bearing
                    //     Speed: $speed
                    //     Time: $time
                    //   ''');
                    // });
                  },
                  child: Text('Start Location Service')),
              ElevatedButton(
                  onPressed: () {
                    BackgroundLocation.stopLocationService();
                  },
                  child: Text('Stop Location Service')),
              ElevatedButton(
                  onPressed: () {
                    getCurrentLocation();
                  },
                  child: Text('Get Current Location')),
            ],
          ),
        ),
      ),
    );
  }

  Widget locationData(String data) {
    return Text(
      data,
      style: TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
      textAlign: TextAlign.center,
    );
  }

  void getCurrentLocation() {
    BackgroundLocation().getCurrentLocation().then((location) {
      print('This is current Location ' + location.toMap().toString());
    });
  }

  @override
  void dispose() {
    // Cancel the subscription when the widget is disposed
    _locationSubscription.cancel();
    BackgroundLocation.stopLocationService();
    super.dispose();
  }
}
