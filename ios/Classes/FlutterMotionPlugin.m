#import "FlutterMotionPlugin.h"
#if __has_include(<flutter_motion/flutter_motion-Swift.h>)
#import <flutter_motion/flutter_motion-Swift.h>
#else
// Support project import fallback if the generated compatibility header
// is not copied when this plugin is created as a library.
// https://forums.swift.org/t/swift-static-libraries-dont-copy-generated-objective-c-header/19816
#import "flutter_motion-Swift.h"
#endif

@implementation FlutterMotionPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterMotionPlugin registerWithRegistrar:registrar];
}
@end
