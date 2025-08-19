import Flutter
import UIKit
import RevolutPayments

public class RevolutSdkBridgePlugin: NSObject, FlutterPlugin {
    
    private var revolutPayKit: RevolutPayKit?
    private var isInitialized = false
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "revolut_sdk_bridge", binaryMessenger: registrar.messenger())
        let instance = RevolutSdkBridgePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "isInitialized":
            handleIsInitialized(result: result)
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
              let merchantPublicKey = args["clientId"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Missing merchant public key", details: nil))
            return
        }
        
        let environment = args["environment"] as? String ?? "sandbox"
        
        do {
            // Initialize Revolut Pay SDK according to official documentation
            let config = RevolutPayKit.Configuration(
                merchantPublicKey: merchantPublicKey,
                environment: environment == "production" ? .production : .sandbox
            )
            
            revolutPayKit = RevolutPayKit(configuration: config)
            isInitialized = true
            result(true)
        } catch {
            result(FlutterError(code: "INITIALIZATION_ERROR", message: error.localizedDescription, details: nil))
        }
    }
    
    private func handleIsInitialized(result: @escaping FlutterResult) {
        result(isInitialized)
    }
    
    private func handleCreateRevolutPayButton(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard isInitialized, let revolutPayKit = revolutPayKit else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "Revolut Pay SDK not initialized", details: nil))
            return
        }
        
        guard let args = call.arguments as? [String: Any],
              let orderToken = args["orderToken"] as? String else {
            result(FlutterError(code: "INVALID_ARGUMENTS", message: "Order token is required", details: nil))
            return
        }
        
        let amount = args["amount"] as? Int ?? 0
        let currency = args["currency"] as? String ?? "GBP"
        let email = args["email"] as? String
        let shouldRequestShipping = args["shouldRequestShipping"] as? Bool ?? false
        let savePaymentMethodForMerchant = args["savePaymentMethodForMerchant"] as? Bool ?? false
        
        // Create the Revolut Pay button
        let button = revolutPayKit.button(
            orderToken: orderToken,
            amount: amount,
            currency: currency,
            email: email,
            shouldRequestShipping: shouldRequestShipping,
            savePaymentMethodForMerchant: savePaymentMethodForMerchant
        ) { [weak self] paymentResult in
            switch paymentResult {
            case .success:
                let response: [String: Any] = [
                    "success": true,
                    "status": "completed",
                    "message": "Revolut Pay payment completed successfully"
                ]
                result(response)
            case .failure(let error):
                let response: [String: Any] = [
                    "success": false,
                    "status": "failed",
                    "error": error.localizedDescription
                ]
                result(response)
            }
        }
        
        // Return button configuration for Flutter to display
        let buttonConfig: [String: Any] = [
            "type": "revolut_pay_button",
            "orderToken": orderToken,
            "amount": amount,
            "currency": currency,
            "email": email ?? "",
            "shouldRequestShipping": shouldRequestShipping,
            "savePaymentMethodForMerchant": savePaymentMethodForMerchant
        ]
        
        result(buttonConfig)
    }
    
    private func handleGetPlatformVersion(result: @escaping FlutterResult) {
        result("iOS " + UIDevice.current.systemVersion)
    }
}
