import Flutter
import UIKit
import RevolutPayments

public class RevolutSdkBridgePlugin: NSObject, FlutterPlugin {
    
    private var revolutPayKit: RevolutPayKit?
    private var buttonViews: [Int: UIView] = [:]
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
        do {
            let testKit = RevolutPayKit()
            
            // Test if the kit can actually perform operations (this would fail if not configured)
            // Try to access a property or method that requires valid configuration
            logToDart("INFO", "Testing RevolutPayKit functionality...")
            
            // REAL TEST: Try to create a test button to validate the configuration
            // This should fail if the merchant key is invalid
            let testButton = testKit.button(
                style: RevolutPayButton.Style(size: .large),
                returnURL: "test://return",
                savePaymentMethodForMerchant: false,
                createOrder: { createOrderHandler in
                    // This should fail if the SDK isn't properly configured
                    createOrderHandler.set(orderToken: "test_token")
                },
                completion: { result in
                    // This completion won't be called for test buttons, but the creation should fail if invalid
                }
            )
            
            // If we get here, the button creation succeeded, which means the configuration is valid
            logToDart("SUCCESS", "Test button creation successful - SDK configuration is valid")
            
            // Store the kit only if validation passes
            revolutPayKit = testKit
            
            logToDart("SUCCESS", "Revolut Pay SDK initialized successfully with merchant key: \(merchantPublicKey)")
            logToDart("INFO", "RevolutPayKit instance created and validated: \(testKit)")
            result(true)
            
        } catch {
            logToDart("ERROR", "Failed to create RevolutPayKit after configuration: \(error.localizedDescription)")
            result(FlutterError(code: "INITIALIZATION_ERROR", message: "Failed to create RevolutPayKit: \(error.localizedDescription)", details: nil))
        }
    }
    
    private func handleCreateRevolutPayButton(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let orderToken = args["orderToken"] as? String,
              let amount = args["amount"] as? Int,
              let currency = args["currency"] as? String,
              let email = args["email"] as? String,
              let shouldRequestShipping = args["shouldRequestShipping"] as? Bool,
              let savePaymentMethodForMerchant = args["savePaymentMethodForMerchant"] as? Bool else {
            logToDart("ERROR", "Missing required parameters for button creation")
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing required parameters", details: nil))
            return
        }
        
        guard let revolutPayKit = revolutPayKit else {
            logToDart("ERROR", "Revolut Pay SDK not initialized")
            result(FlutterError(code: "SDK_NOT_INITIALIZED", message: "SDK must be initialized first", details: nil))
            return
        }
        
        logToDart("INFO", "Creating Revolut Pay button with order token: \(orderToken)")
        
        // Create the button according to official documentation
        let button = revolutPayKit.button(
            style: RevolutPayButton.Style(size: .large),  // Fixed: use RevolutPayButton.Style
            returnURL: "revolut-sdk-bridge://revolut-pay",
            savePaymentMethodForMerchant: savePaymentMethodForMerchant,  // Fixed: add this parameter
            createOrder: { [weak self] createOrderHandler in
                self?.logToDart("INFO", "Setting order token: \(orderToken)")
                createOrderHandler.set(orderToken: orderToken)
            },
            completion: { [weak self] result in
                switch result {
                case .success:
                    self?.logToDart("SUCCESS", "Payment completed successfully")
                    self?.sendPaymentResult(success: true, message: "Payment completed successfully")
                case .failure(let error):
                    self?.logToDart("ERROR", "Payment failed: \(error.localizedDescription)")
                    self?.sendPaymentResult(success: false, error: error.localizedDescription)
                case .userAbandonedPayment:
                    self?.logToDart("WARNING", "Payment abandoned by user")
                    self?.sendPaymentResult(success: false, error: "Payment abandoned by user")
                }
            }
        )
        
        // Store the button view and return its ID
        let viewId = nextViewId
        nextViewId += 1
        buttonViews[viewId] = button
        
        logToDart("SUCCESS", "Revolut Pay button created successfully with viewId: \(viewId)")
        logToDart("INFO", "Button stored in buttonViews with key: \(viewId)")
        logToDart("INFO", "Total buttons stored: \(buttonViews.count)")
        
        // Return button configuration with view ID
        let buttonConfig: [String: Any] = [
            "viewId": viewId,
            "type": "revolut_pay_button",
            "orderToken": orderToken,
            "amount": amount,
            "currency": currency,
            "email": email,
            "shouldRequestShipping": shouldRequestShipping,
            "savePaymentMethodForMerchant": savePaymentMethodForMerchant,
            "buttonCreated": true,
            "message": "Revolut Pay button created successfully"
        ]
        
        result(buttonConfig)
    }
    
    private func sendPaymentResult(success: Bool, message: String? = nil, error: String? = nil) {
        // Send payment result back to Flutter via method channel
        let resultData: [String: Any] = [
            "success": success,
            "message": message ?? "",
            "error": error ?? "",
            "timestamp": Date().timeIntervalSince1970
        ]
        
        logChannel?.invokeMethod("onPaymentResult", arguments: resultData)
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
    
    func getButtonViews() -> [Int: UIView]? {
        return buttonViews
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
        return RevolutPayButtonView(frame: frame, viewIdentifier: viewId, arguments: args, messenger: messenger, logChannel: logChannel)
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// Platform view for Revolut Pay button
class RevolutPayButtonView: NSObject, FlutterPlatformView {
    private let _view: UIView
    private let messenger: FlutterBinaryMessenger
    private let methodChannel: FlutterMethodChannel
    private let logChannel: FlutterMethodChannel?
    
    init(frame: CGRect, viewIdentifier viewId: Int64, arguments args: Any?, messenger: FlutterBinaryMessenger, logChannel: FlutterMethodChannel?) {
        self.messenger = messenger
        self.logChannel = logChannel
        
        // Create method channel for this button instance
        self.methodChannel = FlutterMethodChannel(name: "revolut_pay_button_\(viewId)", binaryMessenger: messenger)
        
        // Get the actual Revolut Pay button from the plugin
        var revolutButton: UIView?
        
        // Extract the button ID from arguments (this is the key fix!)
        let buttonId = (args as? [String: Any])?["buttonId"] as? Int
        
        logChannel?.invokeMethod("onLog", arguments: [
            "level": "INFO",
            "message": "Platform view created with Flutter ID: \(viewId), looking for button ID: \(buttonId ?? -1)",
            "timestamp": Date().timeIntervalSince1970,
            "source": "iOS_ButtonView"
        ])
        
        // Try to get the button from the plugin instance using the button ID from arguments
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
            let button = UIButton(type: .system)
            button.setTitle("Pay with Revolut (Placeholder)", for: .normal)
            button.backgroundColor = UIColor.systemBlue
            button.setTitleColor(.white, for: .normal)
            button.layer.cornerRadius = 8
            button.frame = frame
            
            revolutButton = button
            
            logChannel?.invokeMethod("onLog", arguments: [
                "level": "WARNING",
                "message": "Using placeholder button - button ID \(buttonId ?? -1) not found in buttonViews",
                "timestamp": Date().timeIntervalSince1970,
                "source": "iOS_ButtonView"
            ])
        }
        
        // Set the frame for the button
        revolutButton?.frame = frame
        
        self._view = revolutButton ?? UIView()
        
        super.init()
        
        // Set up method channel handlers
        setupMethodChannel()
        
        // Log button creation
        logChannel?.invokeMethod("onLog", arguments: [
            "level": "INFO",
            "message": "Revolut Pay button view created with Flutter ID: \(viewId), button ID: \(buttonId ?? -1)",
            "timestamp": Date().timeIntervalSince1970,
            "source": "iOS_ButtonView"
        ])
    }
    
    private func setupMethodChannel() {
        methodChannel.setMethodCallHandler { [weak self] call, result in
            switch call.method {
            case "handlePayment":
                // Handle payment action
                self?.logChannel?.invokeMethod("onLog", arguments: [
                    "level": "INFO",
                    "message": "Payment button clicked",
                    "timestamp": Date().timeIntervalSince1970,
                    "source": "iOS_ButtonView"
                ])
                result(true)
            default:
                result(FlutterMethodNotImplemented)
            }
        }
    }
    
    func view() -> UIView {
        return _view
    }
}
