#import "FlutterPaymentsPlugin.h"
#import <flutter_payments/flutter_payments-Swift.h>

@implementation FlutterPaymentsPlugin
+ (void)registerWithRegistrar:(NSObject<FlutterPluginRegistrar>*)registrar {
  [SwiftFlutterPaymentsPlugin registerWithRegistrar:registrar];
}
@end
