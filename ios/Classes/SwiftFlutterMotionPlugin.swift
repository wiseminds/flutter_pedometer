import Flutter
import UIKit

import CoreMotion


public class SwiftFlutterMotionPlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "com.flutter_pedometer.motion_detector/method", binaryMessenger: registrar.messenger())
     let activityRecognitionHandler = ActivityRecognition()
        let stepDetectionChannel = FlutterEventChannel.init(name: "com.flutter_pedometer.activity_recognition/event", binaryMessenger: registrar.messenger())
        stepDetectionChannel.setStreamHandler(activityRecognitionHandler)

        let motionDetectorHandler = MotionDetection()
        let motionDetectorChannel = FlutterEventChannel.init(name: "com.flutter_pedometer.motion_detector/event", binaryMessenger: registrar.messenger())
        motionDetectorChannel.setStreamHandler(motionDetectorHandler)

        registrar.addMethodCallDelegate(motionDetectorHandler, channel: channel)
  }

  
}



/// ActivityRecognition, handles pedestrian status streaming
public class ActivityRecognition: NSObject, FlutterStreamHandler {
    private let activityManager = CMMotionActivityManager()
    private var running = false
    private var motion = "unknown"
    private var eventSink: FlutterEventSink?

    private func handleEvent(event: String) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit step count event to Flutter
        eventSink!(event)
    }

    private func stopTrackingActivityType() {
     activityManager.stopActivityUpdates();
    }

    public func startTrackingActivityType() {
  activityManager.startActivityUpdates(to: OperationQueue.main) {
      [weak self] (activity: CMMotionActivity?) in

      guard let activity = activity else { return }


      DispatchQueue.main.async {
          if activity.walking {
            print("Walking")
              self?.motion = "walking"
          } else if activity.stationary { 
            print("Stationary")
              self?.motion = "stationary"
          } else if activity.running { 
            print("Running")
              self?.motion = "running"
          } else if activity.automotive { 
            print("Automotive")
              self?.motion = "automotive"
          } else {
             print("Unknown")
              self?.motion = "unknown"
          }
          self?.handleEvent(event: self?.motion ?? "")
      }
  }
}

    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        if #available(iOS 10.0, *) {
            if (!CMMotionActivityManager.isActivityAvailable()) {
                eventSink(FlutterError(code: "3", message: "Step Count is not available", details: nil))
            }
            startTrackingActivityType()
            
        } else {
            eventSink(FlutterError(code: "1", message: "Requires iOS 10.0 minimum", details: nil))
        }
        return nil
    }

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil

        if (running) {
            
            self.stopTrackingActivityType();
            running = false
            motion = "unknown"
        }
        return nil
    }
     
}

/// MotionDetection, handles step count streaming
public class MotionDetection: NSObject, FlutterStreamHandler, FlutterPlugin {
    private let pedometer = CMPedometer()
    private var running = false
    private var eventSink: FlutterEventSink?

    private func handleEvent(data: [String: Any?]) {
        // If no eventSink to emit events to, do nothing (wait)
        if (eventSink == nil) {
            return
        }
        // Emit step count event to Flutter
        eventSink!(data)
    }

     public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        
          let args = call.arguments as? [String: Any]
        
        switch call.method {
            
        case "query":
           let s = args?["start"] as! Double
           let e = args?["end"] as! Double
        //    print("\(s), \(e)")
           
             
           let start = Date(timeIntervalSince1970: s / 1000)
           let end = Date(timeIntervalSince1970: e / 1000)

        //    print("\(start), \(end)")
            
            
                pedometer.queryPedometerData(from: start, to:end) { (data, error) in
                    DispatchQueue.main.async {
                        print(data  as Any)
                        if #available(iOS 10.0, *) {
                            result( [
                                "numberOfSteps": data?.numberOfSteps.intValue ?? 0.0,
                                "averageActivePace": data?.averageActivePace?.doubleValue ?? 0.0,
                                "currentPace": data?.currentPace?.doubleValue ?? 0.0,
                                "distance": data?.distance?.doubleValue ?? 0,
                                "floorsAscended": data?.floorsAscended?.intValue ?? 0,
                                "floorsDescended": data?.floorsDescended?.intValue ?? 0,
                                "startDate": (data?.startDate.timeIntervalSince1970 ?? 0) * 1000,
                                "endDate":(( data?.endDate.timeIntervalSince1970 ?? 0) * 1000)
                            ] as  [String: Any?] )
                        } else {
                           result(nil)
                        }
                              
                    }
                }
           
         
            
            
         
        default:
            result(FlutterMethodNotImplemented)
        }
        
        
    }


  public static func register(with registrar: FlutterPluginRegistrar) {
        print( "Pedometer tried to register which is not allowed")
    }
    

   
    public func onListen(withArguments arguments: Any?, eventSink: @escaping FlutterEventSink) -> FlutterError? {
        self.eventSink = eventSink
        if #available(iOS 10.0, *) {
            if (!CMPedometer.isStepCountingAvailable()) {
                eventSink(FlutterError(code: "3", message: "Step Count is not available", details: nil))
            }
            else if (!running) {
                running = true
                pedometer.startUpdates(from: Date()) {
                    pedometerData, error in
                    guard let pedometerData = pedometerData, error == nil else { return }
                    
              
                    DispatchQueue.main.async {
                        self.handleEvent(data: [
                            "numberOfSteps": pedometerData.numberOfSteps.intValue,
                            "averageActivePace": pedometerData.averageActivePace?.doubleValue,
                            "currentPace": pedometerData.currentPace?.doubleValue,
                            "distance": pedometerData.distance?.doubleValue,
                            "floorsAscended": pedometerData.floorsAscended?.intValue,
                            "startDate": pedometerData.startDate.timeIntervalSince1970 * 1000
                                               ])
                    }
                }
            }
        } else {
            eventSink(FlutterError(code: "1", message: "Requires iOS 10.0 minimum", details: nil))
        }
        return nil
    }
    
   

    public func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationCenter.default.removeObserver(self)
        eventSink = nil

        if (running) {
            pedometer.stopUpdates()
            running = false
        }
        return nil
    }
}

// open func queryPedometerData(from start: Date, to end: Date, withHandler handler: @escaping CoreMotion.CMPedometerHandler)
