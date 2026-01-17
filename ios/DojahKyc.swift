import UIKit
import Foundation
import DojahWidget
import React

// Extension to convert dictionary to ExtraUserData (for React Native CLI compatibility)
extension Dictionary where Key == String, Value == Any {
    func toExtraUserData() -> ExtraUserData {
        let userDataDict = self["userData"] as? [String: Any]
        let govDataDict = self["govData"] as? [String: Any]
        let govIdDict = self["govId"] as? [String: Any]
        let locationDict = self["location"] as? [String: Any]
        let businessDataDict = self["businessData"] as? [String: Any]
        let address = self["address"] as? String
        let metadata = self["metadata"] as? [String: Any]
        
        return ExtraUserData(
            userData: UserBioData(
                firstName: userDataDict?["firstName"] as? String,
                lastName: userDataDict?["lastName"] as? String,
                dob: userDataDict?["dob"] as? String,
                email: userDataDict?["email"] as? String
            ),
            govData: ExtraGovData(
                bvn: govDataDict?["bvn"] as? String,
                dl: govDataDict?["dl"] as? String,
                nin: govDataDict?["nin"] as? String,
                vnin: govDataDict?["vnin"] as? String
            ),
            govId: ExtraGovIdData(
                national: govIdDict?["national"] as? String,
                passport: govIdDict?["passport"] as? String,
                dl: govIdDict?["dl"] as? String,
                voter: govIdDict?["voter"] as? String,
                nin: govIdDict?["nin"] as? String,
                others: govIdDict?["others"] as? String
            ),
            location: ExtraLocationData(
                longitude: locationDict?["longitude"] as? String,
                latitude: locationDict?["latitude"] as? String
            ),
            businessData: ExtraBusinessData(
                cac: businessDataDict?["cac"] as? String
            ),
            address: address,
            metadata: metadata
        )
    }
}


// Custom NavigationController that prevents duplicate presentations
class SafeDojahNavigationController: UINavigationController {
    private var isPresenting = false
    
    override func present(_ viewControllerToPresent: UIViewController, animated: Bool, completion: (() -> Void)? = nil) {
        // Check if we're already presenting something
        if isPresenting {
            print("⚠️ Already presenting, preventing duplicate: \(String(describing: type(of: viewControllerToPresent)))")
            completion?()
            return
        }
        
        // Check if this view controller is already in the navigation stack
        if viewControllers.contains(where: { 
            type(of: $0) == type(of: viewControllerToPresent)
        }) {
            print("⚠️ ViewController already in navigation stack: \(String(describing: type(of: viewControllerToPresent)))")
            completion?()
            return
        }
        
        // Check if we're already presenting something
        if presentedViewController != nil {
            print("⚠️ NavigationController already has a presentedViewController")
            completion?()
            return
        }
        
        // Mark as presenting
        isPresenting = true
        
        // Call super to actually present
        super.present(viewControllerToPresent, animated: animated) { [weak self] in
            self?.isPresenting = false
            completion?()
        }
    }
    
    override func dismiss(animated: Bool, completion: (() -> Void)? = nil) {
        isPresenting = false
        super.dismiss(animated: animated, completion: completion)
    }
}

class DojahNavigationControllerDelegate: NSObject, UINavigationControllerDelegate {
    var onDidShow: (UIViewController) -> Void = { _ in }
    
    func navigationController(_ navigationController: UINavigationController,
                              didShow viewController: UIViewController,
                              animated: Bool) {
        print("📱 Did show: \(viewController)")
        onDidShow(viewController)
    }
    
    func setOnDidShow(_ onDidShow: @escaping (UIViewController) -> Void) {
        self.onDidShow = onDidShow
    }
}

class DojahPresentationControllerDelegate: NSObject, UIAdaptivePresentationControllerDelegate {
    var onDidDismiss: () -> Void = { }
    
    func presentationControllerDidDismiss(_ presentationController: UIPresentationController) {
        print("🛑 Modal was dismissed manually")
        onDidDismiss()
    }
    
    func setOnDidDismiss(_ onDidDismiss: @escaping () -> Void) {
        self.onDidDismiss = onDidDismiss
    }
}

@objc(DojahKyc)
class DojahKyc: RCTEventEmitter, RCTBridgeDelegate {
    
    // Track Dojah state
    private var isDojahActive = false
    private var dojahNavController: SafeDojahNavigationController?
    private var prevController: UIViewController? // Track previous controller for DJDisclaimer handling
    private var hasSeenSDKInit = false // Track if we've seen SDKInitViewController before
    private var navDelegate = DojahNavigationControllerDelegate()
    private var presentationDelegate = DojahPresentationControllerDelegate()
    
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
    
    override func supportedEvents() -> [String]! {
        return ["onChange"]
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
    
    private func getTopViewController() -> UIViewController? {
        // Try multiple approaches to find the root view controller
        // This handles React Native's window hierarchy setup
        
        // Approach 1: Try window scene (iOS 13+)
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            // Try the key window first
            if let keyWindow = windowScene.windows.first(where: { $0.isKeyWindow }),
               let rootViewController = keyWindow.rootViewController {
                var topViewController = rootViewController
                while let presentedViewController = topViewController.presentedViewController {
                    topViewController = presentedViewController
                }
                return topViewController
            }
            
            // Try any window with a root view controller
            if let window = windowScene.windows.first(where: { $0.rootViewController != nil }),
               let rootViewController = window.rootViewController {
                var topViewController = rootViewController
                while let presentedViewController = topViewController.presentedViewController {
                    topViewController = presentedViewController
                }
                return topViewController
            }
        }
        
        // Approach 2: Fallback to delegate's window (for older React Native setups)
        if let delegate = UIApplication.shared.delegate,
           let window = delegate.window,
           let rootViewController = window?.rootViewController {
            var topViewController = rootViewController
            while let presentedViewController = topViewController.presentedViewController {
                topViewController = presentedViewController
            }
            return topViewController
        }
        
        print("⚠️ Could not find root view controller using any method")
        return nil
    }
    
    private func resolveSdkResult() {
        let vStatus = DojahWidgetSDK.getVerificationResultStatus()
        let status = vStatus.isEmpty ? "closed" : vStatus
        
        print("📊 Resolving SDK result: \(status)")
        
        // Send event to React Native if bridge is valid
        if self.bridge != nil && !self.bridge.isLoading {
            self.sendEvent(withName: "onChange", body: ["status": status])
        }
        
        // Clear state
        self.prevController = nil
        self.hasSeenSDKInit = false
        
        // Dismiss the navigation controller
        self.dismissDojahController()
        
        // Reset flag
        self.isDojahActive = false
    }
    
    private func dismissDojahController() {
        DispatchQueue.main.async { [weak self] in
            self?.dojahNavController?.dismiss(animated: true) {
                self?.dojahNavController = nil
            }
        }
    }
    
    @objc(launch:withReferenceId:withEmail:withExtraData:withResolver:withRejecter:)
    func launch(
        widgetId: String,
        referenceId: Any?,
        email: Any?,
        extraData: Any?,
        resolve: @escaping RCTPromiseResolveBlock,
        reject: @escaping RCTPromiseRejectBlock
    ) -> Void {
        // Handle null values - JavaScript null becomes NSNull in Objective-C
        // Convert NSNull or nil to empty string
        let safeReferenceId: String = {
            if referenceId is NSNull || referenceId == nil {
                return ""
            }
            return (referenceId as? String) ?? ""
        }()
        
        let safeEmail: String = {
            if email is NSNull || email == nil {
                return ""
            }
            return (email as? String) ?? ""
        }()
        
        // Parse extraData from React Native
        // extraData is a dictionary containing: userData, govData, govId, location, businessData, address, metadata
        var parsedExtraData: [String: Any]? = nil
        
        if let extraDataDict = extraData as? [String: Any], !extraDataDict.isEmpty {
            parsedExtraData = [:]
            
            // Parse userData
            if let userData = extraDataDict["userData"] as? [String: Any], !userData.isEmpty {
                var parsedUserData: [String: Any] = [:]
                if let firstName = userData["firstName"] as? String { parsedUserData["firstName"] = firstName }
                if let lastName = userData["lastName"] as? String { parsedUserData["lastName"] = lastName }
                if let dob = userData["dob"] as? String { parsedUserData["dob"] = dob }
                if let email = userData["email"] as? String { parsedUserData["email"] = email }
                if !parsedUserData.isEmpty { parsedExtraData?["userData"] = parsedUserData }
            }
            
            // Parse govData
            if let govData = extraDataDict["govData"] as? [String: Any], !govData.isEmpty {
                var parsedGovData: [String: Any] = [:]
                if let bvn = govData["bvn"] as? String { parsedGovData["bvn"] = bvn }
                if let dl = govData["dl"] as? String { parsedGovData["dl"] = dl }
                if let nin = govData["nin"] as? String { parsedGovData["nin"] = nin }
                if let vnin = govData["vnin"] as? String { parsedGovData["vnin"] = vnin }
                if !parsedGovData.isEmpty { parsedExtraData?["govData"] = parsedGovData }
            }
            
            // Parse govId
            if let govId = extraDataDict["govId"] as? [String: Any], !govId.isEmpty {
                var parsedGovId: [String: Any] = [:]
                if let national = govId["national"] as? String { parsedGovId["national"] = national }
                if let passport = govId["passport"] as? String { parsedGovId["passport"] = passport }
                if let dl = govId["dl"] as? String { parsedGovId["dl"] = dl }
                if let voter = govId["voter"] as? String { parsedGovId["voter"] = voter }
                if let nin = govId["nin"] as? String { parsedGovId["nin"] = nin }
                if let others = govId["others"] as? String { parsedGovId["others"] = others }
                if !parsedGovId.isEmpty { parsedExtraData?["govId"] = parsedGovId }
            }
            
            // Parse location
            if let location = extraDataDict["location"] as? [String: Any], !location.isEmpty {
                var parsedLocation: [String: Any] = [:]
                if let latitude = location["latitude"] as? String { parsedLocation["latitude"] = latitude }
                if let longitude = location["longitude"] as? String { parsedLocation["longitude"] = longitude }
                if !parsedLocation.isEmpty { parsedExtraData?["location"] = parsedLocation }
            }
            
            // Parse businessData
            if let businessData = extraDataDict["businessData"] as? [String: Any], !businessData.isEmpty {
                var parsedBusinessData: [String: Any] = [:]
                if let cac = businessData["cac"] as? String { parsedBusinessData["cac"] = cac }
                if !parsedBusinessData.isEmpty { parsedExtraData?["businessData"] = parsedBusinessData }
            }
            
            // Parse address
            if let address = extraDataDict["address"] {
                if !(address is NSNull) {
                    if let addressString = address as? String {
                        parsedExtraData?["address"] = addressString
                    }
                }
            }
            
            // Parse metadata
            if let metadata = extraDataDict["metadata"] as? [String: Any], !metadata.isEmpty {
                parsedExtraData?["metadata"] = metadata
            }
        }
        
        // Use parsed extraData or nil if empty
        let extraDataForSDK = (parsedExtraData != nil && !parsedExtraData!.isEmpty) ? parsedExtraData : nil
        
        guard let rootVC = getTopViewController() else {
            print("⚠️ Failed to get top view controller")
            reject("NO_ROOT_VIEW_CONTROLLER", "Failed to get top view controller", nil)
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Reset state for new launch
            self.prevController = nil
            self.isDojahActive = false
            self.hasSeenSDKInit = false
            
            // Create safe navigation controller for Dojah (prevents duplicate presentations)
            let dojahNavController = SafeDojahNavigationController()
            dojahNavController.modalPresentationStyle = .fullScreen
            self.dojahNavController = dojahNavController
            
            // Set delegate BEFORE presenting (important!)
            dojahNavController.delegate = self.navDelegate
            
            // Detect modal dismissal (for cancel)
            dojahNavController.presentationController?.delegate = self.presentationDelegate
            
            // Set up presentation delegate callback
            self.presentationDelegate.setOnDidDismiss { [weak self] in
                guard let self = self else { return }
                print("🛑 Modal was dismissed manually")
                self.resolveSdkResult()
            }
            
            // Track Dojah flow - simplified like original but with proper closing logic
            self.navDelegate.setOnDidShow { [weak self] vc in
                guard let self = self else { return }
                
                // Use String(describing: vc) like the original code
                let vcName = String(describing: vc)
                print("🔄 onDidShow: \(vcName)")
                
                // Match original + Flutter logic:
                // 1. If not DojahWidget, resolve (but only if we were in Dojah)
                if !vcName.contains("DojahWidget") {
                    if self.isDojahActive {
                        print("🚪 Not DojahWidget - resolving")
                        self.resolveSdkResult()
                    }
                    return
                }
                
                // Mark as active when we see Dojah screens
                self.isDojahActive = true
                
                // 2. If DJDisclaimer with prevController, pop to root (like original)
                if vcName.contains("DojahWidget.DJDisclaimer") && self.prevController != nil {
                    print("📱 DJDisclaimer with prevController - popping to root")
                    self.dojahNavController?.popToRootViewController(animated: false)
                    return
                }
                
                // 3. If not SDKInitViewController, track as prevController (like original)
                if !vcName.contains("DojahWidget.SDKInitViewController") {
                    self.prevController = vc
                    print("✅ Tracking prevController: \(vcName)")
                } else {
                    // 4. SDKInitViewController - resolve (matches Flutter's "else" case)
                    // Resolve if we've seen it before OR if we've progressed
                    if self.hasSeenSDKInit || self.prevController != nil {
                        print("📱 SDKInitViewController - resolving")
                        self.resolveSdkResult()
                    } else {
                        // First time seeing SDKInitViewController - allow to continue
                        print("📱 SDKInitViewController on initial launch - allowing to continue")
                        self.hasSeenSDKInit = true
                    }
                }
            }
            
            // Present modally and wait for completion to ensure view hierarchy is ready
            rootVC.present(dojahNavController, animated: true) {
                // Add a small delay to ensure view hierarchy is fully laid out
                // This helps with camera session initialization timing
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                    // Initialize SDK after presentation completes and view is laid out
                    // This ensures the view hierarchy is fully set up before camera access
                    // Convert dictionary to ExtraUserData if method is available in SDK
                    // If toExtraUserData() doesn't exist, this will need to be handled differently
                    let extraUserDataForSDK: ExtraUserData? = {
                        guard let extraDataDict = extraDataForSDK else { return ExtraUserData() }
                        // Try to use toExtraUserData() if available in SDK (works in Expo)
                        return extraDataDict.toExtraUserData()
                    }()
                    
                    DojahWidgetSDK.initialize(
                        widgetID: widgetId,
                        referenceID: safeReferenceId,
                        emailAddress: safeEmail,
                        extraUserData: extraUserDataForSDK ?? ExtraUserData(),
                        source: "ios_react_native_cli",
                        navController: dojahNavController
                    )
                    print("🎯 Dojah SDK initialized: widgetId=\(widgetId), referenceId=\(safeReferenceId), email=\(safeEmail)")
                    // Resolve promise after successful initialization
                    resolve("launched")
                }
            }
        }
    }
}
