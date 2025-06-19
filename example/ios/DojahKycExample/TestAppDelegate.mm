#import "AppDelegate.h"


#import <Firebase.h>


#import <React/RCTBundleURLProvider.h>


#import <UserNotifications/UserNotifications.h>
#import <RNCPushNotificationIOS.h>


#import <React/RCTBridge.h>
#import <React/RCTRootView.h>


@implementation AppDelegate




// // Required for the register event.
// - (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
// {
//  [RNCPushNotificationIOS didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
// }
// // Required for the notification event. You must call the completion handler after handling the remote notification.
// - (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
// fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
// {
//   [RNCPushNotificationIOS didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
// }
// // Required for the registrationError event.
// - (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
// {
//  [RNCPushNotificationIOS didFailToRegisterForRemoteNotificationsWithError:error];
// }
// // Required for localNotification event
// - (void)userNotificationCenter:(UNUserNotificationCenter *)center
// didReceiveNotificationResponse:(UNNotificationResponse *)response
//          withCompletionHandler:(void (^)(void))completionHandler
// {
//   [RNCPushNotificationIOS didReceiveNotificationResponse:response];
// }


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
 // Initialize the React Native bridge
 RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];


 RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                  moduleName:@"fundr"
                                           initialProperties:nil];
 // self.moduleName = @"fundr";
 // You can add your custom initial props in the dictionary below.
 // They will be passed down to the ViewController used by React Native.
 // self.initialProps = @{};


 [FIRApp configure];


  // Define UNUserNotificationCenter
 UNUserNotificationCenter *center = [UNUserNotificationCenter currentNotificationCenter];
 center.delegate = self;
 UIViewController *rootViewController = [UIViewController new];
 rootViewController.view = rootView;


 // Wrap rootViewController in a UINavigationController
 UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];


 self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
 self.window.rootViewController = navigationController;
 [self.window makeKeyAndVisible];
 return YES;
}






// - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {


//   // Initialize the React Native bridge
//   RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];


//   RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
//                                                    moduleName:@"fundr"
//                                             initialProperties:nil];
//  [FIRApp configure];
//   UIViewController *rootViewController = [UIViewController new];
//   rootViewController.view = rootView;


//   // Wrap rootViewController in a UINavigationController
//   UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];


//   self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//   self.window.rootViewController = navigationController;
//   [self.window makeKeyAndVisible];


//   return YES;
// }






//Called when a notification is delivered to a foreground app.
-(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
{
 completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
}




- (NSURL *)sourceURLForBridge:(RCTBridge *)bridge
{
 return [self bundleURL];
}
- (NSURL *)bundleURL
{
#if DEBUG
 return [[RCTBundleURLProvider sharedSettings] jsBundleURLForBundleRoot:@"index"];
#else
 return [[NSBundle mainBundle] URLForResource:@"main" withExtension:@"jsbundle"];
#endif
}


// Required for the register event.
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
[RNCPushNotificationIOS didRegisterForRemoteNotificationsWithDeviceToken:deviceToken];
}
// Required for the notification event. You must call the completion handler after handling the remote notification.
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
 [RNCPushNotificationIOS didReceiveRemoteNotification:userInfo fetchCompletionHandler:completionHandler];
}
// Required for the registrationError event.
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
[RNCPushNotificationIOS didFailToRegisterForRemoteNotificationsWithError:error];
}
// Required for localNotification event
- (void)userNotificationCenter:(UNUserNotificationCenter *)center
didReceiveNotificationResponse:(UNNotificationResponse *)response
        withCompletionHandler:(void (^)(void))completionHandler
{
 [RNCPushNotificationIOS didReceiveNotificationResponse:response];
}


// //Called when a notification is delivered to a foreground app.
// -(void)userNotificationCenter:(UNUserNotificationCenter *)center willPresentNotification:(UNNotification *)notification withCompletionHandler:(void (^)(UNNotificationPresentationOptions options))completionHandler
// {
//   completionHandler(UNNotificationPresentationOptionSound | UNNotificationPresentationOptionAlert | UNNotificationPresentationOptionBadge);
// }


@end




