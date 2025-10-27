package com.example.revolut_sdk_bridge

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.EventChannel.EventSink
import io.flutter.plugin.common.EventChannel.StreamHandler
import com.revolut.payments.RevolutPaymentsSDK
// import com.revolut.payments.RevolutPayEnvironment
// import com.revolut.payments.RevolutPaymentsSDK
import com.revolut.revolutpay.api.revolutPay
import com.revolut.revolutpay.api.button.ButtonParams
import com.revolut.revolutpay.api.button.Radius
import com.revolut.revolutpay.api.button.Size
import com.revolut.revolutpay.api.button.Variant
import com.revolut.revolutpay.api.button.VariantModes
import com.revolut.revolutpay.api.button.BoxText



/** RevolutSdkBridgePlugin */
class RevolutSdkBridgePlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge")
        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge_events")
        eventChannel.setStreamHandler(object : StreamHandler {
            override fun onListen(arguments: Any?, events: EventSink?) {
                eventSink = events
            }
            override fun onCancel(arguments: Any?) {
                eventSink = null
            }
        })
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${android.os.Build.VERSION.RELEASE}")
            }
            "printHello" -> {
                printHello(result)
            }
            "init" -> {
                init(call, result)
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun printHello(result: Result) {
        println("Hello from Android")
        sendEvent("printHello", mapOf("data" to "Hello from Android"))
    }

    private fun sendEvent(event: String, data: Map<String, Any?>) {
        eventSink?.success(mapOf("method" to event, "data" to data))
    }




    private fun init(call: MethodCall, result: Result) {
        try {
            val merchantPublicKey = call.argument<String>("merchantPublicKey") ?: return result.error("INVALID_ARG", "merchantPublicKey required", null)
            val envStr = call.argument<String>("environment") ?: "SANDBOX"
            val env = if (envStr.uppercase() == "PRODUCTION") RevolutPaymentsSDK.Environment.PRODUCTION else RevolutPaymentsSDK.Environment.SANDBOX
            
            RevolutPaymentsSDK.configure(RevolutPaymentsSDK.Configuration(merchantPublicKey, env))
            result.success(true)
            sendEvent("initSuccess", mapOf("message" to "Revolut Payments SDK initialized"))
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message, null)
            sendEvent("initError", mapOf("error" to e.message))
        }
    }

    private fun createRevolutPayButton(call: MethodCall, result: Result) {
        
    }
    
   

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }
}
