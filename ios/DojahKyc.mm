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

//launch:withReferenceId:withEmail:withUserData:withGovData:withGovId:withLocation:withBuisnessData:withAddress:withMetaData:resolver:rejecter:
RCT_EXTERN_METHOD(
    launch:(NSString *)widgetId
    withReferenceId:(NSString *)referenceId
    withEmail:(NSString *)email
    withUserData:(NSDictionary *)userData
    withGovData:(NSDictionary *)govData
    withGovId:(NSDictionary *)govId
    withLocation:(NSDictionary *)location
    withBuisnessData:(NSDictionary *)businessData
    withAddress:(NSString *)address
    withMetaData:(NSDictionary *)metadata
    resolver:(RCTPromiseResolveBlock)resolve
    rejecter:(RCTPromiseRejectBlock)reject
)
@end

