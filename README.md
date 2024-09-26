# Dojah KYC SDK (React Native)


## Installation

```sh
npm install react-native-dojah_kyc
```

## Android Installation

### Requirements
* Minimum Android SDK version - 21
* Supported targetSdkVersion - 34

In your android root/build.gradle file set maven path:
```
...
allprojects {
    repositories {
        ...
        maven { url "https://jitpack.io" }
        maven {
            url = uri("https://maven.pkg.github.com/dojah-inc/sdk-kotlin")
            credentials {
                username = "dojah-inc"
                password = "[TO BE ADDED SOON]"
            }
        }
    }
}
```
Or Set maven path in your root/settings.gradle file:
```
...
dependencyResolutionManagement {
    repositoriesMode.set(RepositoriesMode.FAIL_ON_PROJECT_REPOS)
    repositories {
        ...
        maven { url "https://jitpack.io" }
        maven {
            url = uri("https://maven.pkg.github.com/dojah-inc/sdk-kotlin")
            credentials {
                username = "dojah-inc"
                password = "[TO BE ADDED SOON]"
            }
        }
    }
}
```

### Permissions
For Android you don't need to declare permissions, its already included in the Package.

## IOS Installation

### Requirements
* Minimum iOS version - 14

### Add the following POD dependencies in your Podfile app under your App target

```
  pod 'Realm', '~> 10.52.2', :modular_headers => true
  pod 'DojahWidget', :git => 'https://github.com/shittu33/test-react-native-ios.git', :tag => 'main'
```

example
```
target 'Example' do
  ...
  pod 'Realm', '~> 10.52.2', :modular_headers => true
  pod 'DojahWidget', :git => 'https://github.com/shittu33/test-react-native-ios.git', :tag => '1.0.3'
  ...
end
```

### Make some few changes in your AppDelegate.mm file 

- Add the following imports:

  ```objective-c
    #import <React/RCTBridge.h>
    #import <React/RCTRootView.h>
  ```

- then replace application function in your AppDelegate with the following:

`REMEMBER TO CHANGE THE Your App Name,to the actual name of your App`

```objective-c
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
  
  // Initialize the React Native bridge
  RCTBridge *bridge = [[RCTBridge alloc] initWithDelegate:self launchOptions:launchOptions];

  RCTRootView *rootView = [[RCTRootView alloc] initWithBridge:bridge
                                                   moduleName:@"Your App Name"
                                            initialProperties:nil];

  UIViewController *rootViewController = [UIViewController new];
  rootViewController.view = rootView;

  // Wrap rootViewController in a UINavigationController
  UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:rootViewController];

  self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
  self.window.rootViewController = navigationController;
  [self.window makeKeyAndVisible];

  return YES;
}

```



### Permissions
For IOS, Add the following keys to your Info.plist file:

NSCameraUsageDescription - describe why your app needs access to the camera. This is called Privacy - Camera Usage Description in the visual editor.

NSMicrophoneUsageDescription - describe why your app needs access to the microphone, if you intend to record videos. This is called Privacy - Microphone Usage Description in the visual editor.

NSLocationWhenInUseUsageDescription - describe why your app needs access to the location, if you intend to verify address/location. This is called Privacy - Location Usage Description in the visual editor.



## Usage

```js
import {launchDojahKyc } from 'react-native-dojah_kyc';

launchDojahKyc(
  "{Required: Your_WidgetID}",
  "{Optional: Reference_ID}",
  “{Optional: Email_Address}”
)

```

### SDK Parameters
- `WidgetID` - a `REQUIRED` parameter. You get this ID when you sign up on the Dojoh platform
- `Reference ID` - an `OPTIONAL` parameter that allows you to initialize the SDK for an ongoing verification.
- `Email Address` - an `OPTIONAL` parameter that allows you to initialize the SDK for an ongoing verification


