// #import <React/RCTBridgeModule.h>

// @interface RCT_EXTERN_MODULE(DojahKyc, NSObject)

// RCT_EXTERN_METHOD(multiply:(float)a withB:(float)b
//                  withResolver:(RCTPromiseResolveBlock)resolve
//                  withRejecter:(RCTPromiseRejectBlock)reject)

// + (BOOL)requiresMainQueueSetup
// {
//   return NO;
// }

// @end

#import <Foundation/Foundation.h>
#import <React/RCTBridgeModule.h>

@interface RCT_EXTERN_MODULE(DojahKyc, NSObject)

RCT_EXTERN_METHOD(initialize:(NSString)appName)


RCT_EXTERN_METHOD(
    launch:(NSString *)widgetId
    withReferenceId:(NSString *)referenceId
    withEmail:(NSString *)email
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)
@end

