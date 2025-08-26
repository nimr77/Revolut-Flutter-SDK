package com.revolut.sdk.bridge

import androidx.lifecycle.Lifecycle
import com.revolut.revolutpayments.RevolutPayments
import com.revolut.revolutpay.api.revolutPay
import com.revolut.revolutpay.api.RevolutPayEnvironment
import com.revolut.revolutpay.api.params.Customer
import com.revolut.revolutpay.api.params.DateOfBirth
import com.revolut.revolutpay.domain.model.CountryCode
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import android.content.Context
import android.net.Uri
import androidx.annotation.NonNull

class RevolutSdkBridgePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel : MethodChannel
    private lateinit var eventChannel : EventChannel
    private lateinit var context: Context
    private var activityBinding: ActivityPluginBinding? = null
    private var eventSink: EventSink? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge")
        channel.setMethodCallHandler(this)
        
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge_events")
        eventChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink?) {
                eventSink = events
                // Send a ready event to confirm the event channel is working
                events?.success(mapOf(
                    "method" to "onEventChannelReady",
                    "data" to mapOf(
                        "status" to "ready",
                        "platform" to "android"
                    )
                ))
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> handleInit(call, result)
            "getSdkVersion" -> handleGetSdkVersion(call, result)
            "getPlatformVersion" -> handleGetPlatformVersion(call, result)
            "pay" -> handlePay(call, result)
            "provideButton" -> handleProvideButton(call, result)
            "providePromotionalBannerWidget" -> handleProvidePromotionalBannerWidget(call, result)
            "createController" -> handleCreateController(call, result)
            "setOrderToken" -> handleSetOrderToken(call, result)
            "setSavePaymentMethodForMerchant" -> handleSetSavePaymentMethodForMerchant(call, result)
            "continueConfirmationFlow" -> handleContinueConfirmationFlow(call, result)
            "disposeController" -> handleDisposeController(call, result)
            else -> result.notImplemented()
        }
    }

    private fun handleInit(call: MethodCall, result: Result) {
        try {
            val environment = call.argument<String>("environment") ?: "SANDBOX"
            val returnUri = call.argument<String>("returnUri") ?: ""
            val merchantPublicKey = call.argument<String>("merchantPublicKey") ?: ""
            val requestShipping = call.argument<Boolean>("requestShipping") ?: false
            val customerMap = call.argument<Map<String, Any>>("customer")
            
            if (returnUri.isEmpty() || merchantPublicKey.isEmpty()) {
                result.error("INVALID_ARGUMENTS", "returnUri and merchantPublicKey are required", null)
                return
            }
            
            val revolutEnvironment = when (environment.uppercase()) {
                "MAIN" -> RevolutPayEnvironment.MAIN
                else -> RevolutPayEnvironment.SANDBOX
            }
            
            val customer = customerMap?.let { map ->
                Customer(
                    name = map["name"] as? String,
                    email = map["email"] as? String,
                    phone = map["phone"] as? String,
                    dateOfBirth = (map["dateOfBirth"] as? Map<String, Any>)?.let { dob ->
                        DateOfBirth(
                            _day = (dob["day"] as? Number)?.toInt() ?: 1,
                            _month = (dob["month"] as? Number)?.toInt() ?: 1,
                            _year = (dob["year"] as? Number)?.toInt() ?: 1990
                        )
                    },
                    country = when (map["country"] as? String) {
                        "GB" -> CountryCode.GB
                        "US" -> CountryCode.US
                        else -> CountryCode.GB
                    }
                )
            }
            
            // Initialize the SDK using the correct method
            RevolutPayments.revolutPay.init(
                environment = revolutEnvironment,
                returnUri = Uri.parse(returnUri),
                merchantPublicKey = merchantPublicKey,
                requestShipping = requestShipping,
                customer = customer
            )
            
            result.success(true)
        } catch (e: Exception) {
            result.error("INIT_ERROR", "Failed to initialize Revolut SDK: ${e.message}", null)
        }
    }

    private fun handleGetSdkVersion(call: MethodCall, result: Result) {
        try {
            // Get SDK version information
            result.success(mapOf(
                "version" to "2.8.0",
                "platform" to "Android",
                "buildNumber" to "1"
            ))
        } catch (e: Exception) {
            result.error("GET_SDK_VERSION_ERROR", "Failed to get SDK version: ${e.message}", null)
        }
    }

    private fun handleGetPlatformVersion(call: MethodCall, result: Result) {
        try {
            result.success("Android ${android.os.Build.VERSION.RELEASE}")
        } catch (e: Exception) {
            result.error("GET_PLATFORM_VERSION_ERROR", "Failed to get platform version: ${e.message}", null)
        }
    }

    private fun handlePay(call: MethodCall, result: Result) {
        try {
            val orderToken = call.argument<String>("orderToken") ?: ""
            val savePaymentMethodForMerchant = call.argument<Boolean>("savePaymentMethodForMerchant") ?: false
            
            if (orderToken.isEmpty()) {
                result.error("INVALID_ARGUMENTS", "orderToken is required", null)
                return
            }
            
            // TODO: Implement actual payment flow with Revolut SDK
            // For now, return success to prevent crashes
            result.success(true)
            
            // Send event to Flutter side
            sendEvent("onPaymentStatusUpdate", mapOf(
                "status" to "initiated",
                "orderToken" to orderToken
            ))
        } catch (e: Exception) {
            result.error("PAY_ERROR", "Failed to initiate payment: ${e.message}", null)
        }
    }

    private fun handleProvideButton(call: MethodCall, result: Result) {
        try {
            val buttonParams = call.argument<Map<String, Any>>("buttonParams")
            
            // TODO: Implement actual button creation with Revolut SDK
            // For now, return mock data to prevent crashes
            val buttonData = mapOf(
                "buttonId" to "mock_button_${System.currentTimeMillis()}",
                "isEnabled" to true,
                "buttonType" to "pay",
                "buttonParams" to buttonParams
            )
            
            result.success(buttonData)
        } catch (e: Exception) {
            result.error("PROVIDE_BUTTON_ERROR", "Failed to provide button: ${e.message}", null)
        }
    }

    private fun handleProvidePromotionalBannerWidget(call: MethodCall, result: Result) {
        try {
            val promoParams = call.argument<Map<String, Any>>("promoParams")
            val themeId = call.argument<String>("themeId")
            
            // TODO: Implement actual banner creation with Revolut SDK
            // For now, return mock data to prevent crashes
            val bannerData = mapOf(
                "bannerId" to "mock_banner_${System.currentTimeMillis()}",
                "isVisible" to true,
                "bannerType" to "promotional",
                "promoParams" to promoParams,
                "themeId" to themeId
            )
            
            result.success(bannerData)
        } catch (e: Exception) {
            result.error("PROVIDE_BANNER_ERROR", "Failed to provide banner: ${e.message}", null)
        }
    }

    private fun handleCreateController(call: MethodCall, result: Result) {
        try {
            // TODO: Implement actual controller creation with Revolut SDK
            // For now, return mock data to prevent crashes
            val controllerData = mapOf(
                "controllerId" to "mock_controller_${System.currentTimeMillis()}",
                "isActive" to true,
                "canContinue" to false
            )
            
            result.success(controllerData)
        } catch (e: Exception) {
            result.error("CREATE_CONTROLLER_ERROR", "Failed to create controller: ${e.message}", null)
        }
    }

    private fun handleSetOrderToken(call: MethodCall, result: Result) {
        try {
            val orderToken = call.argument<String>("orderToken") ?: ""
            val controllerId = call.argument<String>("controllerId") ?: ""
            
            if (orderToken.isEmpty() || controllerId.isEmpty()) {
                result.error("INVALID_ARGUMENTS", "orderToken and controllerId are required", null)
                return
            }
            
            // TODO: Implement actual order token setting with Revolut SDK
            // For now, return success to prevent crashes
            result.success(true)
        } catch (e: Exception) {
            result.error("SET_ORDER_TOKEN_ERROR", "Failed to set order token: ${e.message}", null)
        }
    }

    private fun handleSetSavePaymentMethodForMerchant(call: MethodCall, result: Result) {
        try {
            val savePaymentMethodForMerchant = call.argument<Boolean>("savePaymentMethodForMerchant") ?: false
            val controllerId = call.argument<String>("controllerId") ?: ""
            
            if (controllerId.isEmpty()) {
                result.error("INVALID_ARGUMENTS", "controllerId is required", null)
                return
            }
            
            // TODO: Implement actual save payment method setting with Revolut SDK
            // For now, return success to prevent crashes
            result.success(true)
        } catch (e: Exception) {
            result.error("SET_SAVE_PAYMENT_METHOD_ERROR", "Failed to set save payment method: ${e.message}", null)
        }
    }

    private fun handleContinueConfirmationFlow(call: MethodCall, result: Result) {
        try {
            val controllerId = call.argument<String>("controllerId") ?: ""
            
            if (controllerId.isEmpty()) {
                result.error("INVALID_ARGUMENTS", "controllerId is required", null)
                return
            }
            
            // TODO: Implement actual confirmation flow continuation with Revolut SDK
            // For now, return success to prevent crashes
            result.success(true)
            
            // Send event to Flutter side
            sendEvent("onControllerStateChange", mapOf(
                "controllerId" to controllerId,
                "state" to "continuing"
            ))
        } catch (e: Exception) {
            result.error("CONTINUE_CONFIRMATION_FLOW_ERROR", "Failed to continue confirmation flow: ${e.message}", null)
        }
    }

    private fun handleDisposeController(call: MethodCall, result: Result) {
        try {
            val controllerId = call.argument<String>("controllerId") ?: ""
            
            if (controllerId.isEmpty()) {
                result.error("INVALID_ARGUMENTS", "controllerId is required", null)
                return
            }
            
            // TODO: Implement actual controller disposal with Revolut SDK
            // For now, return success to prevent crashes
            result.success(true)
        } catch (e: Exception) {
            result.error("DISPOSE_CONTROLLER_ERROR", "Failed to dispose controller: ${e.message}", null)
        }
    }

    private fun sendEvent(method: String, data: Map<String, Any>) {
        try {
            eventSink?.success(mapOf(
                "method" to method,
                "data" to data
            ))
        } catch (e: Exception) {
            // Log the error but don't crash
            android.util.Log.w("RevolutSdkBridge", "Failed to send event: $method", e)
        }
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivity() {
        activityBinding = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activityBinding = binding
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activityBinding = null
    }
}
