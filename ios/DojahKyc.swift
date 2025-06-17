
import UIKit
import Foundation
import DojahWidget
import React


class DojahNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    var onDidShow: (UIViewController) -> Void = { _ in }
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        print("Did show: \(viewController)")
        onDidShow(viewController)
    }

    func navigationController(_ navigationController: UINavigationController,
                              willShow viewController: UIViewController,
                              animated: Bool) {
        print("Will show: \(viewController)")
    }
    
    func setOnDidShow(_ onDidShow: @escaping (UIViewController) -> Void) {
        self.onDidShow = onDidShow
    }
}

@objc(DojahKyc)
class DojahKyc: RCTEventEmitter, RCTBridgeDelegate {
  @objc override static func requiresMainQueueSetup() -> Bool {
      return false
  }
  
  let navDelegate = DojahNavigationControllerDelegate()

  var navCtrl:UINavigationController? = nil
  
  var prevController:UIViewController? = nil
    
  override init() {
    super.init()
    
    DispatchQueue.main.async {
      self.navCtrl = UIApplication.shared.keyWindow?.rootViewController as? UINavigationController
      if self.navCtrl != nil {
        self.navCtrl!.delegate = self.navDelegate
      }
    }
  }
  
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


  @objc(launch:withReferenceId:withEmail:resolver:rejecter:)
    func launch(
      _ widgetId:String,
      withReferenceId referenceId:String,
      withEmail email:String,
      resolver resolve: @escaping RCTPromiseResolveBlock,
      rejecter reject: @escaping RCTPromiseRejectBlock
    ) {
        navDelegate.setOnDidShow { vc in
            print("onDidShow: \(vc)")
            //return result from DojahWidget once verification
            //is done,failed or cancel
            if(!String(describing:vc).contains("DojahWidget")){
                let vStatus = DojahWidgetSDK.getVerificationResultStatus()
                let status = if(vStatus.isEmpty){  "closed"} else {vStatus}
              
              resolve(status)
              print("resolve onDidShow: \(vc)")

                
              self.prevController = nil
            }else if(String(describing:vc).contains("DojahWidget.DJDisclaimer")
                     && self.prevController != nil){
                self.navCtrl?.popToRootViewController(animated: false)
            }else if(!String(describing:vc).contains("DojahWidget.SDKInitViewController")){
                self.prevController = vc
            }
        }
          

       if(navCtrl != nil){
           do{
             DojahWidgetSDK.initialize(widgetID: widgetId,referenceID: referenceId,emailAddress: email, navController: navCtrl!)
           }catch{
             reject("no-launch", "Could not launch Dojah Widget", error)
           }
      }else{
          reject("no-launch", "Could not launch Dojah Widget", nil)
          //throw error status to react native
            print("rootViewController is nil")
        }
    }

}
