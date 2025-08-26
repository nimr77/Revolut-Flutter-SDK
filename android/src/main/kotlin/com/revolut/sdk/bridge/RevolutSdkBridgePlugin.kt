package com.revolut.sdk.bridge

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import android.app.Activity
import android.content.Context
import android.view.View
import android.view.ViewGroup
import android.widget.LinearLayout
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleOwner
import androidx.lifecycle.LifecycleRegistry
import androidx.lifecycle.ProcessLifecycleOwner
import org.json.JSONObject

// Import Revolut Pay SDK classes
import com.revolut.revolutpay.RevolutPay
import com.revolut.revolutpay.RevolutPayEnvironment
import com.revolut.revolutpay.ui.button.RevolutPayButton
import com.revolut.revolutpay.ui.button.ButtonParams
import com.revolut.revolutpay.ui.button.VariantModes
import com.revolut.revolutpay.ui.promotional.PromoBannerParams
import com.revolut.revolutpay.controller.Controller
import com.revolut.revolutpay.controller.ConfirmationFlow
import com.revolut.revolutpay.callback.OrderResultCallback

/** RevolutSdkBridgePlugin */
class RevolutSdkBridgePlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var isInitialized = false
    private var currentController: Controller? = null
    private lateinit var callbackHandler: RevolutPayCallbackHandler
    
    // Map to store multiple controllers by ID
    private val controllers = mutableMapOf<String, ConfirmationFlow>()

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge")
        channel.setMethodCallHandler(this)
        
        // Initialize callback handler
        callbackHandler = RevolutPayCallbackHandler(channel)
        
        // Register platform view factory for Revolut Pay button
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "revolut_pay_button",
            RevolutPayButtonViewFactory(flutterPluginBinding.binaryMessenger)
        )
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        callbackHandler.sendLifecycleEvent("ACTIVITY_ATTACHED", mapOf(
            "activityName" to activity?.javaClass?.simpleName
        ))
    }

    override fun onDetachedFromActivity() {
        callbackHandler.sendLifecycleEvent("ACTIVITY_DETACHED", mapOf(
            "activityName" to activity?.javaClass?.simpleName
        ))
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        callbackHandler.sendLifecycleEvent("ACTIVITY_REATTACHED", mapOf(
            "activityName" to activity?.javaClass?.simpleName
        ))
    }

    override fun onDetachedFromActivityForConfigChanges(binding: ActivityPluginBinding) {
        callbackHandler.sendLifecycleEvent("ACTIVITY_DETACHED_CONFIG_CHANGE", mapOf(
            "activityName" to activity?.javaClass?.simpleName
        ))
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        try {
            when (call.method) {
                "init" -> handleInit(call, result)
                "pay" -> handlePay(call, result)
                "provideButton" -> handleProvideButton(call, result)
                "providePromotionalBannerWidget" -> handleProvidePromotionalBannerWidget(call, result)
                "createController" -> handleCreateController(call, result)
                "setOrderToken" -> handleSetOrderToken(call, result)
                "setSavePaymentMethodForMerchant" -> handleSetSavePaymentMethodForMerchant(call, result)
                "continueConfirmationFlow" -> handleContinueConfirmationFlow(call, result)
                "getPlatformVersion" -> handleGetPlatformVersion(result)
                "disposeController" -> handleDisposeController(call, result)
                "getSdkVersion" -> handleGetSdkVersion(result)
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            callbackHandler.sendError("METHOD_CALL_ERROR", "UNEXPECTED_ERROR", e.message ?: "Unknown error", e.stackTraceToString())
            result.error("UNEXPECTED_ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun handleInit(call: MethodCall, result: Result) {
        try {
            val environmentStr = call.argument<String>("environment") ?: "MAIN"
            val returnUri = call.argument<String>("returnUri")
            val merchantPublicKey = call.argument<String>("merchantPublicKey")
            val requestShipping = call.argument<Boolean>("requestShipping") ?: false
            val customerData = call.argument<Map<String, dynamic>>("customer")

            if (returnUri == null || merchantPublicKey == null) {
                result.error("INVALID_ARGUMENTS", "Missing required parameters: returnUri and merchantPublicKey", null)
                return
            }

            // Validate input data
            val initData = SdkInitData(
                environment = when (environmentStr.uppercase()) {
                    "SANDBOX" -> RevolutEnvironment.SANDBOX
                    else -> RevolutEnvironment.MAIN
                },
                returnUri = returnUri,
                merchantPublicKey = merchantPublicKey,
                requestShipping = requestShipping,
                customer = customerData?.let { createCustomerFromMap(it) }
            )

            if (!RevolutPayDataValidator.validateSdkInitData(initData)) {
                result.error("VALIDATION_ERROR", "Invalid initialization data", null)
                return
            }

            val environment = when (initData.environment) {
                RevolutEnvironment.SANDBOX -> RevolutPayEnvironment.SANDBOX
                else -> RevolutPayEnvironment.MAIN
            }

            val customer = initData.customer?.toSdkCustomer()

            // Initialize Revolut Pay SDK
            RevolutPay.init(
                environment = environment,
                returnUri = initData.returnUri,
                merchantPublicKey = initData.merchantPublicKey,
                requestShipping = initData.requestShipping,
                customer = customer
            )

            isInitialized = true
            
            callbackHandler.sendSuccess("init", mapOf(
                "environment" to environmentStr,
                "requestShipping" to requestShipping,
                "hasCustomer" to (customer != null)
            ))
            
            result.success(true)
        } catch (e: Exception) {
            callbackHandler.sendError("init", "INIT_ERROR", e.message ?: "Unknown initialization error", e.stackTraceToString())
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun handlePay(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Revolut Pay SDK not initialized", null)
            return
        }

        try {
            val orderToken = call.argument<String>("orderToken")
            val savePaymentMethodForMerchant = call.argument<Boolean>("savePaymentMethodForMerchant") ?: false

            if (orderToken == null || activity == null) {
                result.error("INVALID_ARGUMENTS", "Order token and activity are required", null)
                return
            }

            val lifecycle = (activity as? LifecycleOwner)?.lifecycle ?: ProcessLifecycleOwner.get().lifecycle

            val callback = callbackHandler.createOrderResultCallback()

            RevolutPay.pay(
                context = activity!!,
                orderToken = orderToken,
                savePaymentMethodForMerchant = savePaymentMethodForMerchant,
                lifecycle = lifecycle,
                callback = callback
            )

            callbackHandler.sendPaymentStatusUpdate("PAYMENT_INITIATED", null, mapOf(
                "orderToken" to orderToken,
                "savePaymentMethod" to savePaymentMethodForMerchant
            ))

            result.success(true)
        } catch (e: Exception) {
            callbackHandler.sendError("pay", "PAY_ERROR", e.message ?: "Unknown payment error", e.stackTraceToString())
            result.error("PAY_ERROR", e.message, null)
        }
    }

    private fun handleProvideButton(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Revolut Pay SDK not initialized", null)
            return
        }

        try {
            val buttonParams = call.argument<Map<String, dynamic>>("buttonParams")
            val params = buttonParams?.let { createButtonParamsFromMap(it) }

            if (params == null) {
                result.error("INVALID_ARGUMENTS", "Invalid button parameters", null)
                return
            }

            if (activity == null) {
                result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available", null)
                return
            }

            val button = RevolutPay.provideButton(activity!!, params)
            
            val buttonId = button.hashCode().toString()
            
            callbackHandler.sendSuccess("provideButton", mapOf(
                "buttonId" to buttonId,
                "buttonParams" to buttonParams
            ))
            
            result.success(mapOf(
                "buttonCreated" to true,
                "buttonId" to buttonId
            ))
        } catch (e: Exception) {
            callbackHandler.sendError("provideButton", "BUTTON_ERROR", e.message ?: "Unknown button creation error", e.stackTraceToString())
            result.error("BUTTON_ERROR", e.message, null)
        }
    }

    private fun handleProvidePromotionalBannerWidget(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Revolut Pay SDK not initialized", null)
            return
        }

        try {
            val promoParams = call.argument<Map<String, dynamic>>("promoParams")
            val themeId = call.argument<String>("themeId")

            val params = promoParams?.let { createPromoBannerParamsFromMap(it) }

            if (params == null) {
                result.error("INVALID_ARGUMENTS", "Invalid promotional banner parameters", null)
                return
            }

            if (activity == null) {
                result.error("ACTIVITY_NOT_AVAILABLE", "Activity is not available", null)
                return
            }

            val banner = RevolutPay.providePromotionalBannerWidget(
                context = activity!!,
                params = params,
                themeId = themeId
            )

            val bannerId = banner.hashCode().toString()
            
            callbackHandler.sendSuccess("providePromotionalBannerWidget", mapOf(
                "bannerId" to bannerId,
                "themeId" to themeId
            ))

            result.success(mapOf(
                "bannerCreated" to true,
                "bannerId" to bannerId
            ))
        } catch (e: Exception) {
            callbackHandler.sendError("providePromotionalBannerWidget", "BANNER_ERROR", e.message ?: "Unknown banner creation error", e.stackTraceToString())
            result.error("BANNER_ERROR", e.message, null)
        }
    }

    private fun handleCreateController(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Revolut Pay SDK not initialized", null)
            return
        }

        try {
            val controller = RevolutPay.createController(
                clickHandler = { confirmationFlow ->
                    val controllerId = confirmationFlow.hashCode().toString()
                    controllers[controllerId] = confirmationFlow
                    
                    callbackHandler.sendControllerStateChange(controllerId, "CREATED", mapOf(
                        "timestamp" to System.currentTimeMillis()
                    ))
                    
                    callbackHandler.sendSuccess("onConfirmationFlowCreated", mapOf(
                        "controllerId" to controllerId
                    ))
                },
                callback = callbackHandler.createOrderResultCallback()
            )

            val controllerId = controller.hashCode().toString()
            
            callbackHandler.sendSuccess("createController", mapOf(
                "controllerId" to controllerId
            ))

            result.success(mapOf(
                "controllerCreated" to true,
                "controllerId" to controllerId
            ))
        } catch (e: Exception) {
            callbackHandler.sendError("createController", "CONTROLLER_ERROR", e.message ?: "Unknown controller creation error", e.stackTraceToString())
            result.error("CONTROLLER_ERROR", e.message, null)
        }
    }

    private fun handleSetOrderToken(call: MethodCall, result: Result) {
        try {
            val orderToken = call.argument<String>("orderToken")
            val controllerId = call.argument<String>("controllerId")

            if (orderToken == null || controllerId == null) {
                result.error("INVALID_ARGUMENTS", "Order token and controller ID are required", null)
                return
            }

            val confirmationFlow = controllers[controllerId]
            if (confirmationFlow != null) {
                confirmationFlow.setOrderToken(orderToken)
                
                callbackHandler.sendControllerStateChange(controllerId, "ORDER_TOKEN_SET", mapOf(
                    "orderToken" to orderToken
                ))
                
                result.success(true)
            } else {
                result.error("CONTROLLER_NOT_FOUND", "Controller not found", null)
            }
        } catch (e: Exception) {
            callbackHandler.sendError("setOrderToken", "SET_ORDER_TOKEN_ERROR", e.message ?: "Unknown error setting order token", e.stackTraceToString())
            result.error("SET_ORDER_TOKEN_ERROR", e.message, null)
        }
    }

    private fun handleSetSavePaymentMethodForMerchant(call: MethodCall, result: Result) {
        try {
            val savePaymentMethodForMerchant = call.argument<Boolean>("savePaymentMethodForMerchant") ?: false
            val controllerId = call.argument<String>("controllerId")

            if (controllerId == null) {
                result.error("INVALID_ARGUMENTS", "Controller ID is required", null)
                return
            }

            val confirmationFlow = controllers[controllerId]
            if (confirmationFlow != null) {
                confirmationFlow.setSavePaymentMethodForMerchant(savePaymentMethodForMerchant)
                
                callbackHandler.sendControllerStateChange(controllerId, "SAVE_PAYMENT_METHOD_SET", mapOf(
                    "savePaymentMethod" to savePaymentMethodForMerchant
                ))
                
                result.success(true)
            } else {
                result.error("CONTROLLER_NOT_FOUND", "Controller not found", null)
            }
        } catch (e: Exception) {
            callbackHandler.sendError("setSavePaymentMethodForMerchant", "SET_SAVE_PAYMENT_METHOD_ERROR", e.message ?: "Unknown error setting save payment method", e.stackTraceToString())
            result.error("SET_SAVE_PAYMENT_METHOD_ERROR", e.message, null)
        }
    }

    private fun handleContinueConfirmationFlow(call: MethodCall, result: Result) {
        try {
            val controllerId = call.argument<String>("controllerId")

            if (controllerId == null) {
                result.error("INVALID_ARGUMENTS", "Controller ID is required", null)
                return
            }

            val confirmationFlow = controllers[controllerId]
            if (confirmationFlow != null) {
                confirmationFlow.continueConfirmationFlow()
                
                callbackHandler.sendControllerStateChange(controllerId, "CONFIRMATION_FLOW_CONTINUED", mapOf(
                    "timestamp" to System.currentTimeMillis()
                ))
                
                result.success(true)
            } else {
                result.error("CONTROLLER_NOT_FOUND", "Controller not found", null)
            }
        } catch (e: Exception) {
            callbackHandler.sendError("continueConfirmationFlow", "CONTINUE_CONFIRMATION_FLOW_ERROR", e.message ?: "Unknown error continuing confirmation flow", e.stackTraceToString())
            result.error("CONTINUE_CONFIRMATION_FLOW_ERROR", e.message, null)
        }
    }

    private fun handleDisposeController(call: MethodCall, result: Result) {
        try {
            val controllerId = call.argument<String>("controllerId")

            if (controllerId == null) {
                result.error("INVALID_ARGUMENTS", "Controller ID is required", null)
                return
            }

            val removed = controllers.remove(controllerId)
            if (removed != null) {
                callbackHandler.sendControllerStateChange(controllerId, "DISPOSED", mapOf(
                    "timestamp" to System.currentTimeMillis()
                ))
                
                result.success(true)
            } else {
                result.error("CONTROLLER_NOT_FOUND", "Controller not found", null)
            }
        } catch (e: Exception) {
            callbackHandler.sendError("disposeController", "DISPOSE_CONTROLLER_ERROR", e.message ?: "Unknown error disposing controller", e.stackTraceToString())
            result.error("DISPOSE_CONTROLLER_ERROR", e.message, null)
        }
    }

    private fun handleGetSdkVersion(result: Result) {
        try {
            // This would need to be implemented based on the actual SDK
            val sdkVersion = "2.0.0" // Placeholder
            result.success(mapOf(
                "sdkVersion" to sdkVersion,
                "platform" to "Android"
            ))
        } catch (e: Exception) {
            result.error("SDK_VERSION_ERROR", e.message, null)
        }
    }

    private fun handleGetPlatformVersion(result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    // Helper methods to create SDK objects from Flutter data
    private fun createCustomerFromMap(customerData: Map<String, dynamic>): CustomerData {
        val name = customerData["name"] as? String
        val email = customerData["email"] as? String
        val phone = customerData["phone"] as? String
        val dateOfBirthData = customerData["dateOfBirth"] as? Map<String, dynamic>
        val countryData = customerData["country"] as? Map<String, dynamic>

        val dateOfBirth = dateOfBirthData?.let { 
            DateOfBirthData(
                day = it["day"] as? Int ?: 1,
                month = it["month"] as? Int ?: 1,
                year = it["year"] as? Int ?: 1990
            )
        }
        
        val country = countryData?.let { 
            CountryData(value = it["value"] as? String ?: "GB")
        }

        return CustomerData(
            name = name,
            email = email,
            phone = phone,
            dateOfBirth = dateOfBirth,
            country = country
        )
    }

    private fun createButtonParamsFromMap(params: Map<String, dynamic>): ButtonParamsData {
        val radius = when ((params["radius"] as? String)?.uppercase()) {
            "SMALL" -> ButtonRadius.SMALL
            "LARGE" -> ButtonRadius.LARGE
            else -> ButtonRadius.MEDIUM
        }
        
        val size = when ((params["size"] as? String)?.uppercase()) {
            "SMALL" -> ButtonSize.SMALL
            "MEDIUM" -> ButtonSize.MEDIUM
            else -> ButtonSize.LARGE
        }
        
        val boxText = when ((params["boxText"] as? String)?.uppercase()) {
            "GET_CASHBACK_VALUE" -> BoxText.GET_CASHBACK_VALUE
            "GET_CASHBACK_PERCENTAGE" -> BoxText.GET_CASHBACK_PERCENTAGE
            else -> BoxText.NONE
        }
        
        val variantModes = params["variantModes"]?.let { variantData ->
            val variantMap = variantData as? Map<String, dynamic>
            if (variantMap != null) {
                val darkTheme = when ((variantMap["darkTheme"] as? String)?.uppercase()) {
                    "DARK" -> ButtonVariant.DARK
                    else -> ButtonVariant.LIGHT
                }
                val lightTheme = when ((variantMap["lightTheme"] as? String)?.uppercase()) {
                    "DARK" -> ButtonVariant.DARK
                    else -> ButtonVariant.LIGHT
                }
                VariantModesData(darkTheme = darkTheme, lightTheme = lightTheme)
            } else null
        }

        return ButtonParamsData(
            radius = radius,
            size = size,
            boxText = boxText,
            boxTextCurrency = params["boxTextCurrency"] as? String,
            variantModes = variantModes
        )
    }

    private fun createPromoBannerParamsFromMap(params: Map<String, dynamic>): PromoBannerParamsData {
        return PromoBannerParamsData(
            customParam = params["customParam"] as? String
        )
    }
}

// Platform view factory for Revolut Pay button
class RevolutPayButtonViewFactory(private val messenger: MethodChannel.BinaryMessenger) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val creationParams = args as? Map<String?, Any?>
        return RevolutPayButtonView(context, viewId, messenger, creationParams)
    }
}

// Platform view for Revolut Pay button
class RevolutPayButtonView(
    private val context: Context,
    private val viewId: Int,
    private val messenger: MethodChannel.BinaryMessenger,
    private val creationParams: Map<String?, Any?>?
) : PlatformView {
    
    private val button: RevolutPayButton
    private val methodChannel: MethodChannel
    
    init {
        // Create method channel for this button instance
        methodChannel = MethodChannel(messenger, "revolut_pay_button_$viewId")
        
        // Create the Revolut Pay button with default parameters
        val buttonParams = ButtonParams.Builder()
            .radius(ButtonParams.Radius.MEDIUM)
            .size(ButtonParams.Size.LARGE)
            .build()
            
        button = RevolutPay.provideButton(context, buttonParams)
        
        // Set up method channel handlers
        setupMethodChannel()
    }
    
    private fun setupMethodChannel() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "updateButtonParams" -> {
                    val params = call.argument<Map<String, dynamic>>("params")
                    updateButtonParams(params)
                    result.success(true)
                }
                "setOrderToken" -> {
                    val orderToken = call.argument<String>("orderToken")
                    if (orderToken != null) {
                        // This would need to be integrated with the controller pattern
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Order token is required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun updateButtonParams(params: Map<String, dynamic>?) {
        // Update button parameters if needed
        // This would require recreating the button with new parameters
    }
    
    override fun getView(): View = button
    
    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}
