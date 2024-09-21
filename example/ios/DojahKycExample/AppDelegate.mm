#import "AppDelegate.h"

#import <React/RCTBridge.h>
#import <React/RCTBundleURLProvider.h>
#import <React/RCTRootView.h>

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
  self.moduleName = @"DojahKycExample";
  // You can add your custom initial props in the dictionary below.
  // They will be passed down to the ViewController used by React Native.
  self.initialProps = @{};

  return [super application:application didFinishLaunchingWithOptions:launchOptions];
}

/*
Equivalent Swift code for application funtion:

override func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
  
  // Initialize the React Native bridge
  let bridge = RCTBridge(delegate: self, launchOptions: launchOptions)
  
  let rootView = RCTRootView(bridge: bridge, moduleName: "DojahKycExample", initialProperties: nil)
  
  let rootViewController = UIViewController()
  rootViewController.view = rootView
  
  // Wrap rootViewController in a UINavigationController
  let navigationController = UINavigationController(rootViewController: rootViewController)
  
  self.window = UIWindow(frame: UIScreen.main.bounds)
  self.window?.rootViewController = navigationController
  self.window?.makeKeyAndVisible()
  
  return true
}
*/

// - (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
//  
//   // Initialize the React Native bridge
//   RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];
//
//   RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
//                            moduleName:@"DojahKycExample"
//                       initialProperties:nil];
//
//   UIViewController *rootViewController = [UIViewController new];
//   rootViewController.view = rootView;
//
//   // Wrap rootViewController in a UINavigationController
//   UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];
//
//   self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
//   self.window.rootViewController = navigationController;
//   [self.window makeKeyAndVisible];
//
//   return YES;
// }


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

@end
