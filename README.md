# flutter_motion

[![pub package](https://img.shields.io/pub/v/flutter_motion.svg)](https://pub.dartlang.org/packages/flutter_motion)

Access to CMMotionActivityManager and CMPedometer classes for iOS, android implementation is coming soon.

This plugin gets realtime motion data starting from  the time you started listening


<img src="https://raw.githubusercontent.com/wiseminds/flutter_pedometer/main/screenshot/screenshot1.jpeg" width="200"/> <img src="https://raw.githubusercontent.com/wiseminds/flutter_pedometer/main/screenshot/screenshot2.jpeg" width="200"/> <img src="https://raw.githubusercontent.com/wiseminds/flutter_pedometer/main/screenshot/screenshot3.jpeg" width="200"/>

 

## Permissions for Android
For Android 10 and above add the following permission to the Android manifest:

```dart
<uses-permission android:name="android.permission.ACTIVITY_RECOGNITION" />
```

## Permissions for iOS
Add the following entries to your Info.plist file in the Runner xcode project:

```xml
<key>NSMotionUsageDescription</key>
<string>This application tracks your steps</string>
<key>UIBackgroundModes</key>
<array>
    <string>processing</string>
</array>
```

## Step Count
The step count represents the number of steps taken since the last system boot. 
On Android, any steps taken before installing the application will not be counted.

## Pedestrian Status
The Pedestrian status is either `walking` or `stopped`. In the case that of an error, 
the status will be `unknown`.

## Availability of Sensors
Both Step Count and Pedestrian Status may not be available on some phones:

* It was found that some Samsung phones did not support Step Count or Pedestrian Status
* Older iPhones did not support Pedestrian Status in particular 

There is nothing we can do to solve this problem, unfortunately.

In the case that a sensor is not available, an error will be thrown. It is important that **you** handle this error **yourself**.
## Example Usage

See the [example app](https://github.com/cph-cachet/flutter-plugins/blob/master/packages/pedometer/example/lib/main.dart) for a fully-fledged example.

Below is shown a more generalized example. Remember to set the required permissions, as described above.

``` dart
   StreamSubscription<Activity>? _pedestrianStatusSubscription;
  StreamSubscription<Motion>? _motionDetectorSubscription;
  bool isRunning = false;
  String? _motionError, _activityError;

  late ValueNotifier<Activity> _activityNotifier;
  late ValueNotifier<Motion> _motionNotifier;

  @override
  void initState() {
    _activityNotifier = ValueNotifier(Activity.unknown);
    _motionNotifier = ValueNotifier(const Motion());
    super.initState();
  }

  void onMotion(Motion event) {
    // print(event);
    _motionNotifier.value = event;
  }

  void onPedestrianStatusChanged(Activity event) {
    // print(event);
    _activityNotifier.value = event;
  }

  void onPedestrianStatusError(error) {
    // print('onPedestrianStatusError: $error');
    setState(() {
      _motionError = error.toString();
    });
    // print(_status);
  }

  void onMotionError(error) {
    setState(() {
      _activityError = error.toString();
    });
  }

  _listenToActivity() {
    _pedestrianStatusSubscription = FlutterPedometer.pedestrianStatusStream
        .listen(onPedestrianStatusChanged)
      ..onError(onPedestrianStatusError);
  }

  _listenToMotion() {
    _motionDetectorSubscription = FlutterPedometer.motionDetectorStream
        .listen(onMotion)
      ..onError(onMotionError);
  }

  _start() {
    _listenToActivity();
    _listenToMotion();
    setState(() {
      isRunning = true;
    });
  }

  _stop() {
    _pedestrianStatusSubscription?.cancel();
    _motionDetectorSubscription?.cancel();
    setState(() {
      isRunning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
        lazy: false,
        create: (context) => _motionNotifier,
        builder: (c, child) => ChangeNotifierProvider(
              lazy: false,
              create: (context) => _activityNotifier,
              builder: (c, child) => MaterialApp(
                home: Scaffold(
                  appBar: AppBar(
                    title: const Text('FlutterPedometer  example app'),
                  ),
                  floatingActionButton: FloatingActionButton(
                    onPressed: isRunning ? _stop : _start,
                    child: isRunning
                        ? const Icon(Icons.pause)
                        : const Icon(Icons.play_arrow),
                  ),
                  body: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: <Widget>[
                      if (_activityError != null) Text(_activityError ?? ''),
                      if (_motionError != null) Text(_motionError ?? ''),
                      Builder(builder: (context) {
                        return ListTile(
                          title: Text(
                              context
                                  .watch<ValueNotifier<Activity>>()
                                  .value
                                  .name,
                              style: Theme.of(context).textTheme.headline4),
                          subtitle: const Text('Activity'),
                        );
                      }),
                      Builder(builder: (context) {
                        var motion = context.watch<ValueNotifier<Motion>>();
                        return Column(
                          children: [
                            ListTile(
                              title: Text(
                                  motion.value.averageActivePace
                                      .toStringAsFixed(2),
                                  style: Theme.of(context).textTheme.headline4),
                              subtitle: const Text('averageActivePace'),
                            ),
                            ListTile(
                              title: Text(
                                  motion.value.currentPace.toStringAsFixed(2),
                                  style: Theme.of(context).textTheme.headline4),
                              subtitle: const Text('currentPace'),
                            ),
                            ListTile(
                              title: Text(
                                  motion.value.distance.toStringAsFixed(2),
                                  style: Theme.of(context).textTheme.headline4),
                              subtitle: const Text('distance'),
                            ),
                            ListTile(
                              title: Text(
                                  motion.value.floorsAscended
                                      .toStringAsFixed(2),
                                  style: Theme.of(context).textTheme.headline4),
                              subtitle: const Text('floorsAscended'),
                            ),
                            ListTile(
                              title: Text('${motion.value.numberOfSteps}',
                                  style: Theme.of(context).textTheme.headline4),
                              subtitle: const Text('numberOfSteps'),
                            ),
                          ],
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ));
  }
```

### Query motion data between specific dates
``` dart
    FlutterMotion.queryData( DateTime.now().subtract(
                                          const Duration(minutes: 10)),
                                      DateTime.now());
                                 .then((value) => print(value));
```


