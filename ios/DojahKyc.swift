
import UIKit
import Foundation
import DojahWidget
import React

@objc(DojahKyc)
class DojahKyc: RCTEventEmitter, RCTBridgeDelegate {
    func sourceURL(for bridge: RCTBridge) -> URL? {
        
        #if DEBUG
            return RCTBundleURLProvider.sharedSettings().jsBundleURL(forBundleRoot: "index", fallbackExtension: nil)
        #else
            return Bundle.main.url(forResource: "main", withExtension: "jsbundle")!
        #endif
        
    }
    
    
    override var methodQueue: DispatchQueue {
        return DispatchQueue.main;
    }
    
    override class func requiresMainQueueSetup() -> Bool {
        return true;
    }
    
    
    @objc(initialize:)
    func initialize(appName:String) -> Void {
        // Initialize the React Native bridge
        if let bridge = RCTBridge(delegate: self, launchOptions: nil)  {
            // Create a React Native root view with the provided module name
            let rootView = RCTRootView(bridge: bridge, moduleName: appName, initialProperties: nil)
            
            // Create the initial view controller with the React Native view
            let rootViewController = UIViewController()
            rootViewController.view = rootView
            
            // Create a UINavigationController and set it as the window's rootViewController
            let navigationController = UINavigationController(rootViewController: rootViewController)
            
            // Set the window's rootViewController
            if let window = UIApplication.shared.delegate?.window {
                window?.rootViewController = navigationController
                window?.makeKeyAndVisible()
            }
        }else{
            print("bridge is null")
        }
        
        
    }
    
    
    @objc(launch:withReferenceId:withEmail:)
    func launch(widgetId:String, referenceId:String, email:String) -> Void {
        
        
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController else {
            print("no root ctrl")
            return
        }
        print("nav ctrl: $\(rootViewController as? UINavigationController)")
        
        // print("Launched start")
        // let nav: UIViewController? = RCTPresentedViewController()
        // print("nav ctrl is \(nav?.navigationController)")
        
        if(rootViewController as? UINavigationController != nil){
            DojahWidgetSDK.initialize(widgetID: widgetId,referenceID: referenceId,emailAddress: email, navController: rootViewController as! UINavigationController)
            //          DojahWidgetSDK.initializeNormal(widgetID: widgetId,referenceID: referenceId,emailAddress: email, uiController: nav!)
            print("Launched...")
            // print("cached count is: \(DojahWidgetSDK.getCachedWidgetIDs().count)")
            print("native details: Launch=> email:\(email), referenceId:\(referenceId), widgetId:\(widgetId)")
        }else{
            print("rootViewController is nil")
        }

    }
    
    // @objc(launchTest:withB:withResolver:withRejecter:)
    // func launchTest(a: Float, b: Float, resolve:RCTPromiseResolveBlock,reject:RCTPromiseRejectBlock) -> Void {
    //  print("Launched Test")
    //      //  print("count is:\(DojahWidgetSDK.getCachedWidgetIDs().count;)")
    // //  if(DojahWidgetSDK.getCachedWidgetIDs().count > 0){
    // //     resolve("launched more")
    // //   }else{
    // //     resolve("launched 0")
    // //   }
    //  resolve("launched")
    // }
}
