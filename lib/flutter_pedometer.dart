// You have generated a new plugin project without
// specifying the `--platforms` flag. A plugin project supports no platforms is generated.
// To add platforms, run `flutter create -t plugin --platforms <platforms> .` under the same
// directory. You can also find a detailed instruction on how to add platforms in the `pubspec.yaml` at https://flutter.dev/docs/development/packages-and-plugins/developing-packages#plugin-platforms.

import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter_pedometer/models/activity.dart';

import 'models/motion.dart';
export 'models/activity.dart';
export 'models/motion.dart';

// const int _stopped = 0, _walking = 1;

class FlutterPedometer {
  static const EventChannel _activityRecognitionChannel =
      EventChannel('com.flutter_pedometer.activity_recognition');
  static const EventChannel _motionDetectorChannel =
      EventChannel('com.flutter_pedometer.motion_detector');

 
  /// Returns one step at a time.
  /// Events come every time a step is detected.
  static Stream<Activity> get pedestrianStatusStream {
    Stream<Activity> stream = _activityRecognitionChannel
        .receiveBroadcastStream()
        .map((event) => Activity.values
            .where((element) => element.name == event)
            .toList()[0]);
    // if (Platform.isAndroid) return _androidStream(stream);
    return stream;
  }

  /// Returns the steps taken since last system boot.
  /// Events may come with a delay.
  static Stream<Motion> get motionDetectorStream => _motionDetectorChannel
      .receiveBroadcastStream()
      .map((event) => Motion.fromJSON((event as Map<Object?, Object?>)
          .map((key, value) => MapEntry('$key', value))));
}
 