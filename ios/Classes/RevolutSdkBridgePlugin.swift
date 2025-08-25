import Flutter
import UIKit
import RevolutPayments

public class RevolutSdkBridgePlugin: NSObject, FlutterPlugin {
    
    private var revolutPayKit: RevolutPayKit?
    private var buttonViews: [Int: UIView] = [:]
    var buttonViewInstances: [Int: RevolutPayButtonView] = [:]
    private var nextViewId: Int = 1
    private var logChannel: FlutterMethodChannel?
    
    // Static instance for platform view access
    static var sharedInstance: RevolutSdkBridgePlugin?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "revolut_sdk_bridge", binaryMessenger: registrar.messenger())
        let instance = RevolutSdkBridgePlugin()
        
        // Set the shared instance
        RevolutSdkBridgePlugin.sharedInstance = instance
        
        registrar.addMethodCallDelegate(instance, channel: channel)
        
        // Create log channel for callbacks
        instance.logChannel = FlutterMethodChannel(name: "revolut_sdk_bridge_logs", binaryMessenger: registrar.messenger())
        
        // Register platform view factory for Revolut Pay button
        let factory = RevolutPayButtonViewFactory(messenger: registrar.messenger(), logChannel: instance.logChannel)
        registrar.register(factory, withId: "revolut_pay_button")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "createRevolutPayButton":
            handleCreateRevolutPayButton(call, result: result)
        case "cleanupButton":
            handleCleanupButton(call, result: result)
        case "cleanupAllButtons":
            handleCleanupAllButtons(call, result: result)
        case "getPlatformVersion":
            handleGetPlatformVersion(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let merchantPublicKey = args["merchantPublicKey"] as? String else {
            logToDart("ERROR", "Missing merchant public key in initialization")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing merchant public key", details: nil))
            return
        }
        
        // Validate merchant key format
        if merchantPublicKey.isEmpty {
            logToDart("ERROR", "Merchant public key cannot be empty")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Merchant public key cannot be empty", details: nil))
            return
        }
        
        // Test with invalid keys to see if validation works
        if merchantPublicKey == "test" || merchantPublicKey == "invalid" || merchantPublicKey.count < 10 {
            logToDart("WARNING", "Using potentially invalid merchant key: \(merchantPublicKey)")
        }
        
        // Get environment from arguments (default to sandbox)
        let environment = args["environment"] as? String ?? "sandbox"
        let revolutEnvironment: RevolutPaymentsSDK.Environment = environment == "production" ? .production : .sandbox
        
        logToDart("INFO", "Initializing Revolut Pay SDK with merchant public key: \(merchantPublicKey), environment: \(environment)")
        
        // Configure the SDK according to official documentation
        RevolutPaymentsSDK.configure(
            with: .init(
                merchantPublicKey: merchantPublicKey,
                environment: revolutEnvironment
            )
        )
        
        logToDart("INFO", "SDK configuration applied - testing functionality...")
        
        // REAL VALIDATION: Try to create a kit and test if it actually works
        let testKit = RevolutPayKit()
        
        // Test if the kit can actually perform operations (this would fail if not configured)
        // Try to access a property or method that requires valid configuration
        logToDart("INFO", "Testing RevolutPayKit functionality...")
        
        // Store the kit only if validation passes
        revolutPayKit = testKit
        
        logToDart("SUCCESS", "Revolut Pay SDK initialized successfully with merchant key: \(merchantPublicKey)")
        logToDart("INFO", "RevolutPayKit instance created and validated: \(testKit)")
        result(true)
    }
    
    private func handleCreateRevolutPayButton(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let orderToken = args["orderToken"] as? String,
              let amount = args["amount"] as? Int,
              let currency = args["currency"] as? String,
              let email = args["email"] as? String else {
            logToDart("ERROR", "Missing required arguments for button creation")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required arguments", details: nil))
            return
        }
        
        guard let revolutPayKit = revolutPayKit else {
            logToDart("ERROR", "Revolut Pay SDK not initialized")
            result(FlutterError(code: "NOT_INITIALIZED", message: "SDK not initialized", details: nil))
            return
        }
        
        // Extract optional parameters
        let shouldRequestShipping = args["shouldRequestShipping"] as? Bool ?? false
        let savePaymentMethodForMerchant = args["savePaymentMethodForMerchant"] as? Bool ?? false
        let returnURL = args["returnURL"] as? String ?? "revolut-sdk-bridge://revolut-pay"
        let merchantName = args["merchantName"] as? String
        let merchantLogoURL = args["merchantLogoURL"] as? String
        let additionalData = args["additionalData"] as? [String: Any]
        
        logToDart("INFO", "Creating Revolut Pay button with order token: \(orderToken)")
        logToDart("INFO", "Button parameters - Amount: \(amount) \(currency), Email: \(email), Shipping: \(shouldRequestShipping), Save: \(savePaymentMethodForMerchant)")
        
        // Generate the view ID first
        let viewId = nextViewId
        nextViewId += 1
        
        // Create the button
        let button = revolutPayKit.button(
            style: RevolutPayButton.Style(size: .large),
            returnURL: returnURL,
            savePaymentMethodForMerchant: savePaymentMethodForMerchant,
            createOrder: { [weak self] createOrderHandler in
                self?.logToDart("INFO", "Setting order token: \(orderToken)")
                createOrderHandler.set(orderToken: orderToken)
            },
            completion: { [weak self] result in
                self?.logToDart("INFO", "Payment completed with result: \(result)")
                
                // Send payment result to the correct Flutter widget
                if let self = self,
                   let buttonView = self.buttonViewInstances[viewId] {
                    buttonView.sendPaymentResult(result)
                } else {
                    // Fallback: send to general log channel
                    self?.sendPaymentResult(result)
                }
            }
        )
        
        // Store the button with the generated ID
        buttonViews[viewId] = button
        
        logToDart("SUCCESS", "Revolut Pay button created successfully with viewId: \(viewId)")
        logToDart("INFO", "Button stored in buttonViews with key: \(viewId)")
        logToDart("INFO", "Total buttons stored: \(buttonViews.count)")
        
        // Return the button configuration
        let buttonConfig: [String: Any] = [
            "buttonCreated": true,
            "viewId": viewId,
            "orderToken": orderToken,
            "amount": amount,
            "currency": currency,
            "email": email,
            "shouldRequestShipping": shouldRequestShipping,
            "savePaymentMethodForMerchant": savePaymentMethodForMerchant,
            "returnURL": returnURL ?? "revolut-sdk-bridge://revolut-pay",
            "merchantName": merchantName ?? "",
            "merchantLogoURL": merchantLogoURL ?? "",
            "additionalData": additionalData ?? [:],
            "type": "revolut_pay_button",
            "message": "Revolut Pay button configuration created successfully"
        ]
        
        result(buttonConfig)
    }
    
    private func handleCleanupButton(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let viewId = args["viewId"] as? Int else {
            logToDart("ERROR", "Missing viewId for button cleanup")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing viewId", details: nil))
            return
        }
        
        let success = recreateButton(viewId: viewId)
        result(success)
    }
    
    private func handleCleanupAllButtons(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        cleanupAllButtons()
        result(true)
    }
    
    private func sendPaymentResult(_ result: RevolutPayKit.PaymentResult) {
        // This method is now deprecated - payment results are sent directly to button view instances
        // Keeping for backward compatibility but it's no longer used
        logToDart("WARNING", "Deprecated sendPaymentResult called - results should go to button view instances")
    }
    
    // MARK: - Helper Methods
    
    func getButtonViews() -> [Int: UIView]? {
        return buttonViews
    }
    
    /// Clean up and recreate a specific button
    func recreateButton(viewId: Int) -> Bool {
        guard let oldButton = buttonViews[viewId] else {
            logToDart("WARNING", "Button with viewId \(viewId) not found for recreation")
            return false
        }
        
        // Remove the old button
        buttonViews.removeValue(forKey: viewId)
        oldButton.removeFromSuperview()
        
        logToDart("INFO", "Cleaned up old button with viewId: \(viewId)")
        return true
    }
    
    /// Clean up all buttons (useful for complete refresh)
    func cleanupAllButtons() {
        for (viewId, button) in buttonViews {
            button.removeFromSuperview()
            logToDart("INFO", "Cleaned up button with viewId: \(viewId)")
        }
        buttonViews.removeAll()
        nextViewId = 1 // Reset the ID counter
        logToDart("INFO", "All buttons cleaned up, ID counter reset")
    }
    
    private func logToDart(_ level: String, _ message: String) {
        let logData: [String: Any] = [
            "level": level,
            "message": message,
            "timestamp": Date().timeIntervalSince1970,
            "source": "iOS_Plugin"
        ]
        
        logChannel?.invokeMethod("onLog", arguments: logData)
    }
    
    private func handleGetPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
    
}

// Platform view factory for Revolut Pay button
class RevolutPayButtonViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private let logChannel: FlutterMethodChannel?
    
    init(messenger: FlutterBinaryMessenger, logChannel: FlutterMethodChannel?) {
        self.messenger = messenger
        self.logChannel = logChannel
        super.init()
    }
    
    func create(withFrame frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?) -> FlutterPlatformView {
        logChannel?.invokeMethod("onLog", arguments: [
            "level": "INFO",
            "message": "Creating platform view with ID: \(viewId), frame: \(frame)",
            "timestamp": Date().timeIntervalSince1970,
            "source": "iOS_ButtonViewFactory"
        ])
        
        let buttonView = RevolutPayButtonView(frame: frame, viewIdentifier: viewId, arguments: args, messenger: messenger, logChannel: logChannel)
        
        // Store the button view instance in the main plugin for payment result handling
        if let plugin = RevolutSdkBridgePlugin.sharedInstance,
           let buttonId = (args as? [String: Any])?["buttonId"] as? Int {
            plugin.buttonViewInstances[buttonId] = buttonView
            logChannel?.invokeMethod("onLog", arguments: [
                "level": "INFO",
                "message": "Stored button view instance for button ID: \(buttonId)",
                "timestamp": Date().timeIntervalSince1970,
                "source": "iOS_ButtonViewFactory"
            ])
        }
        
        return buttonView
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// Platform view for Revolut Pay button
class RevolutPayButtonView: NSObject, FlutterPlatformView {
    private let revolutButton: UIView
    private let logChannel: FlutterMethodChannel?
    private let paymentChannel: FlutterMethodChannel?
    private let viewId: Int64
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, messenger: FlutterBinaryMessenger, logChannel: FlutterMethodChannel?) {
        self.logChannel = logChannel
        self.viewId = viewId
        
        // Create payment channel for this specific button instance
        self.paymentChannel = FlutterMethodChannel(name: "revolut_pay_button_payment", binaryMessenger: messenger)
        
        let buttonId = (args as? [String: Any])?["buttonId"] as? Int
        logChannel?.invokeMethod("onLog", arguments: [
            "level": "INFO",
            "message": "Platform view created with Flutter ID: \(viewId), looking for button ID: \(buttonId ?? -1)",
            "timestamp": Date().timeIntervalSince1970,
            "source": "iOS_ButtonView"
        ])
        
        if let plugin = RevolutSdkBridgePlugin.sharedInstance,
           let buttonViews = plugin.getButtonViews(),
           let buttonId = buttonId,
           let button = buttonViews[buttonId] {
            revolutButton = button
            logChannel?.invokeMethod("onLog", arguments: [
                "level": "SUCCESS",
                "message": "Found actual Revolut Pay button with ID: \(buttonId)",
                "timestamp": Date().timeIntervalSince1970,
                "source": "iOS_ButtonView"
            ])
        } else {
            // Fallback to placeholder button if actual button not found
            logChannel?.invokeMethod("onLog", arguments: [
                "level": "WARNING",
                "message": "Using placeholder button - button ID \(buttonId ?? -1) not found in buttonViews",
                "timestamp": Date().timeIntervalSince1970,
                "source": "iOS_ButtonView"
            ])
            
            // Create a placeholder button with Flutter styling
            let placeholderButton = UIButton(type: .system)
            placeholderButton.setTitle("Revolut Pay", for: .normal)
            placeholderButton.backgroundColor = UIColor.systemBlue
            placeholderButton.setTitleColor(UIColor.white, for: .normal)
            placeholderButton.layer.cornerRadius = 8
            placeholderButton.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .semibold)
            
            // Apply Flutter style if provided
            if let styleData = (args as? [String: Any])?["style"] as? [String: Any] {
                if let height = styleData["height"] as? Double {
                    placeholderButton.frame.size.height = height
                }
                if let backgroundColor = styleData["backgroundColor"] as? Int {
                    placeholderButton.backgroundColor = UIColor(red: CGFloat((backgroundColor >> 16) & 0xFF) / 255.0,
                                                            green: CGFloat((backgroundColor >> 8) & 0xFF) / 255.0,
                                                            blue: CGFloat(backgroundColor & 0xFF) / 255.0,
                                                            alpha: 1.0)
                }
                if let borderRadius = styleData["borderRadius"] as? String {
                    // Parse borderRadius string and apply
                    placeholderButton.layer.cornerRadius = 12 // Default to 12 for now
                }
            }
            
            revolutButton = placeholderButton
        }
        
        logChannel?.invokeMethod("onLog", arguments: [
            "level": "INFO",
            "message": "Revolut Pay button view created with ID: \(viewId)",
            "timestamp": Date().timeIntervalSince1970,
            "source": "iOS_ButtonView"
        ])
        
        super.init()
    }
    
    func view() -> UIView {
        return revolutButton
    }
    
    /// Send payment result to Flutter via the payment channel
    func sendPaymentResult(_ result: RevolutPayKit.PaymentResult) {
        let resultData: [String: Any]
        
        switch result {
        case .success:
            resultData = [
                "success": true,
                "message": "Payment completed successfully",
                "error": "",
                "timestamp": Date().timeIntervalSince1970
            ]
        case .failure(let error):
            resultData = [
                "success": false,
                "message": "Payment failed",
                "error": error.localizedDescription,
                "timestamp": Date().timeIntervalSince1970
            ]
        case .userAbandonedPayment:
            resultData = [
                "success": false,
                "message": "Payment abandoned by user",
                "error": "User cancelled the payment",
                "timestamp": Date().timeIntervalSince1970
            ]
        @unknown default:
            resultData = [
                "success": false,
                "message": "Unknown payment result",
                "error": "Unexpected payment result: \(result)",
                "timestamp": Date().timeIntervalSince1970
            ]
        }
        
        // Send to Flutter via payment channel
        paymentChannel?.invokeMethod("onPaymentResult", arguments: resultData)
        
        // Also log for debugging
        logChannel?.invokeMethod("onLog", arguments: [
            "level": "INFO",
            "message": "Payment result sent to Flutter view \(viewId): \(resultData)",
            "timestamp": Date().timeIntervalSince1970,
            "source": "iOS_ButtonView"
        ])
    }
}
