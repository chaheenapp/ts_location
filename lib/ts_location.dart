import 'dart:async';
import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// BackgroundLocation plugin to get background
/// lcoation updates in iOS and Android
class BackgroundLocation {
  // The channel to be used for communication.
  // This channel is also refrenced inside both iOS and Abdroid classes
  static const MethodChannel _channel =
      MethodChannel('qa.shaheen.tslocation/methods');

  // StreamController for broadcasting location updates
  static StreamController<Location> _locationUpdatesController =
      StreamController<Location>.broadcast();

  // Expose the stream to allow subscription
  static Stream<Location> get locationUpdates =>
      _locationUpdatesController.stream;

  BackgroundLocation._internal() {
    // _channel.setMethodCallHandler(_locationUpdatedHandler);
  }

  // Factory constructor to access the stream and set up the listener
  factory BackgroundLocation() {
    return BackgroundLocation._internal();
  }

  static Future<void> _locationUpdatedHandler(MethodCall methodCall) async {
    print("method called...........${methodCall.method}");
    if (methodCall.method == 'chaheenLocation') {
      var locationData = Map.from(methodCall.arguments);
      _locationUpdatesController.add(Location.fromMap(locationData));
    } else {
      throw PlatformException(
        code: 'Unimplemented',
        details: 'ts_location for method ${methodCall.method} not implemented.',
      );
    }
  }

  /// Stop receiving location updates
  static stopLocationService() async {
    await _channel.invokeMethod('stop_location_service');
    // Close the StreamController when the service is stopped
    _locationUpdatesController.close();
  }

  /// Start receiving location updated
  static startLocationService(
      {double distanceFilter = 0.0,
      bool forceAndroidLocationManager = false}) async {
    await _channel.invokeMethod('start_location_service', <String, dynamic>{
      'distance_filter': distanceFilter,
      'force_location_manager': forceAndroidLocationManager
    });
    // print("BackgroundLocation._internal set channhl handle");
    // _channel.setMethodCallHandler((MethodCall methodCall) async {
    //   print("method called...........${methodCall.method}");
    //   if (methodCall.method == 'chaheenLocation') {
    //  try {
  
    //       var locationData = Map.from(methodCall.arguments);
    //     _locationUpdatesController.add(Location.fromMap(locationData));
    //  } catch (e) {
    //   print(e.toString());
       
    //  }
    //   }
    // });
    // Initialize a new StreamController if one was closed previously
    // if (!_locationUpdatesController.hasListener) {
    //   _locationUpdatesController = StreamController<Location>.broadcast();
    // }
  }

    /// Register a function to recive location updates as long as the location
  /// service has started
  static getLocationUpdates(Function(Location) location) {
    // add a handler on the channel to recive updates from the native classes
    _channel.setMethodCallHandler((MethodCall methodCall) async {
      if (methodCall.method == 'chaheenLocation') {
               print("Exuting===========> chaheenLocation");
        var locationData = Map.from(methodCall.arguments);
        // Call the user passed function
        location(
          Location(
              latitude: locationData['latitude'],
              longitude: locationData['longitude'],
              altitude: locationData['altitude'],
              accuracy: locationData['accuracy'],
              bearing: locationData['bearing'],
              speed: locationData['speed'],
              time: locationData['time'],
              isMock: locationData['is_mock']),
        );
      }
    });
  }

  static setAndroidNotification(
      {String? title, String? message, String? icon}) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('set_android_notification',
          <String, dynamic>{'title': title, 'message': message, 'icon': icon});
    } else {
      //return Promise.resolve();
    }
  }

  static setAndroidConfiguration(int interval) async {
    if (Platform.isAndroid) {
      return await _channel.invokeMethod('set_configuration', <String, dynamic>{
        'interval': interval.toString(),
      });
    } else {
      //return Promise.resolve();
    }
  }

  /// Get the current location once.
  Future<Location> getCurrentLocation() async {
    var completer = Completer<Location>();

    var _location = Location();
    await getLocationUpdates((location) {
      _location.latitude = location.latitude;
      _location.longitude = location.longitude;
      _location.accuracy = location.accuracy;
      _location.altitude = location.altitude;
      _location.bearing = location.bearing;
      _location.speed = location.speed;
      _location.time = location.time;
      completer.complete(_location);
    });

    return completer.future;
  }

  /// Register a function to recive location updates as long as the location
  /// service has started
  // static getLocationUpdates(Function(Location) location) {
  //   // add a handler on the channel to recive updates from the native classes
  //   _channel.setMethodCallHandler((MethodCall methodCall) async {
  //     print("methodCall: ${methodCall.method}");
  //     if (methodCall.method == 'chaheenLocation') {
  //       var locationData = Map.from(methodCall.arguments);
  //       // Call the user passed function
  //       // location(
  //       //   Location(
  //       //       latitude: locationData['latitude'],
  //       //       longitude: locationData['longitude'],
  //       //       altitude: locationData['altitude'],
  //       //       accuracy: locationData['accuracy'],
  //       //       bearing: locationData['bearing'],
  //       //       speed: locationData['speed'],
  //       //       time: locationData['time'],
  //       //       isMock: locationData['is_mock']),
  //       // );

  //       // Add the location data to the stream
  //   try {
  //         _locationUpdatesController.add(
  //         Location(
  //           latitude: locationData['latitude'],
  //           longitude: locationData['longitude'],
  //           altitude: locationData['altitude'],
  //           accuracy: locationData['accuracy'],
  //           bearing: locationData['bearing'],
  //           speed: locationData['speed'],
  //           time: locationData['time'],
  //           isMock: locationData['is_mock'],
  //         ),
  //       );
  //       print("subscription sent.....");
  //   } catch (e) {
  //     print(e.toString());
      
  //   }
  //     }
  //   });
  // }
}

/// about the user current location
class Location {
  double? latitude;
  double? longitude;
  double? altitude;
  double? bearing;
  double? accuracy;
  double? speed;
  double? time;
  bool? isMock;

  Location(
      {@required this.longitude,
      @required this.latitude,
      @required this.altitude,
      @required this.accuracy,
      @required this.bearing,
      @required this.speed,
      @required this.time,
      @required this.isMock});
  Location.fromMap(Map<dynamic, dynamic> map)
      : latitude = map['latitude'],
        longitude = map['longitude'],
        altitude = map['altitude'],
        accuracy = map['accuracy'],
        bearing = map['bearing'],
        speed = map['speed'],
        time = map['time'],
        isMock = map['is_mock'];
  toMap() {
    var obj = {
      'latitude': latitude,
      'longitude': longitude,
      'altitude': altitude,
      'bearing': bearing,
      'accuracy': accuracy,
      'speed': speed,
      'time': time,
      'is_mock': isMock
    };
    return obj;
  }
}
