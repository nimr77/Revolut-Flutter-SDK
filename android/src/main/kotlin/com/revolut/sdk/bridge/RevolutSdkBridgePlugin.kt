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
import android.widget.Button
import android.graphics.Color
import android.view.ViewGroup
import android.widget.LinearLayout
import org.json.JSONObject

/** RevolutSdkBridgePlugin */
class RevolutSdkBridgePlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var isInitialized = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge")
        channel.setMethodCallHandler(this)
        
        // Register platform view factory for Revolut Pay button
        flutterPluginBinding.platformViewRegistry.registerViewFactory(
            "revolut_pay_button",
            RevolutPayButtonViewFactory(flutterPluginBinding.binaryMessenger)
        )
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "createRevolutPayButton" -> handleCreateRevolutPayButton(call, result)
            "getPlatformVersion" -> handleGetPlatformVersion(result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        try {
            val merchantPublicKey = call.argument<String>("merchantPublicKey")
            val environment = call.argument<String>("environment") ?: "sandbox"

            if (merchantPublicKey == null) {
                result.error("INVALID_ARGUMENTS", "Missing merchant public key", null)
                return
            }

            // Initialize Revolut Pay SDK
            // Note: This is a placeholder - you would need to add the actual Revolut Pay SDK dependency
            // and implement the proper initialization
            isInitialized = true
            result.success(true)
        } catch (e: Exception) {
            result.error("INITIALIZATION_ERROR", e.message, null)
        }
    }
    
    private fun handleCreateRevolutPayButton(call: MethodCall, result: Result) {
        if (!isInitialized) {
            result.error("NOT_INITIALIZED", "Revolut Pay SDK not initialized", null)
            return
        }
        
        try {
            val orderToken = call.argument<String>("orderToken")
            val amount = call.argument<Int>("amount") ?: 0
            val currency = call.argument<String>("currency") ?: "GBP"
            val email = call.argument<String>("email")
            val shouldRequestShipping = call.argument<Boolean>("shouldRequestShipping") ?: false
            val savePaymentMethodForMerchant = call.argument<Boolean>("savePaymentMethodForMerchant") ?: false

            if (orderToken == null) {
                result.error("INVALID_ARGUMENTS", "Order token is required", null)
                return
            }

            // Create button configuration
            val buttonConfig = mapOf(
                "type" to "revolut_pay_button",
                "orderToken" to orderToken,
                "amount" to amount,
                "currency" to currency,
                "email" to (email ?: ""),
                "shouldRequestShipping" to shouldRequestShipping,
                "savePaymentMethodForMerchant" to savePaymentMethodForMerchant,
                "buttonCreated" to true,
                "message" to "Revolut Pay button created successfully"
            )

            result.success(buttonConfig)
        } catch (e: Exception) {
            result.error("BUTTON_CREATION_ERROR", e.message, null)
        }
    }

    private fun handleGetPlatformVersion(result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
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
    
    private val button: Button
    private val methodChannel: MethodChannel
    
    init {
        // Create method channel for this button instance
        methodChannel = MethodChannel(messenger, "revolut_pay_button_$viewId")
        
        // Create the button
        button = Button(context).apply {
            text = "Pay with Revolut"
            setBackgroundColor(Color.parseColor("#0000FF")) // Revolut blue
            setTextColor(Color.WHITE)
            setOnClickListener {
                // Handle button click
                handlePaymentClick()
            }
        }
        
        // Set up method channel handlers
        setupMethodChannel()
    }
    
    private fun setupMethodChannel() {
        methodChannel.setMethodCallHandler { call, result ->
            when (call.method) {
                "handlePayment" -> {
                    // Handle payment action
                    result.success(true)
                }
                else -> result.notImplemented()
            }
        }
    }
    
    private fun handlePaymentClick() {
        // This is where you would integrate with the actual Revolut Pay SDK
        // For now, we'll just send a message back to Flutter
        methodChannel.invokeMethod("paymentButtonClicked", null)
    }
    
    override fun getView(): View = button
    
    override fun dispose() {
        methodChannel.setMethodCallHandler(null)
    }
}
