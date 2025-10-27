package com.example.revolut_sdk_bridge

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** RevolutSdkBridgePlugin */
class RevolutSdkBridgePlugin :
    FlutterPlugin,
    MethodCallHandler {
    // The MethodChannel that will the communication between Flutter and native Android
    //
    // This local reference serves to register the plugin with the Flutter Engine and unregister it
    // when the Flutter Engine is detached from the Activity
    private lateinit var channel: MethodChannel
    private lateinit var handler: RevolutBridgeHandler
    private lateinit var eventChannel: EventChannel
    private var eventSink: EventChannel.EventSink? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge")
        channel.setMethodCallHandler(this)
        handler = RevolutBridgeHandler()

        eventChannel = EventChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge_events")
        eventChannel.setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                eventSink = events
                // Provide emitter to handler so it can send events
                handler.setEventEmitter { payload ->
                    try {
                        eventSink?.success(payload)
                    } catch (_: Throwable) {
                        // Ignore emission failures
                    }
                }
                // Notify Flutter that the event channel is ready
                val readyEvent = mapOf(
                    "method" to "onEventChannelReady",
                    "data" to mapOf(
                        "status" to "ready"
                    )
                )
                eventSink?.success(readyEvent)
            }

            override fun onCancel(arguments: Any?) {
                eventSink = null
                handler.setEventEmitter(null)
            }
        })

        // Register PlatformView for Revolut Pay button
        try {
            val registrar = flutterPluginBinding.platformViewRegistry
            registrar.registerViewFactory(
                "revolut_pay_button",
                RevolutPayButtonFactory(flutterPluginBinding.binaryMessenger) { payload ->
                    try {
                        eventSink?.success(payload)
                    } catch (_: Throwable) {}
                },
            )
        } catch (_: Throwable) {
            // Safe-guard: do not crash if registry API changes
        }
    }

    override fun onMethodCall(
        call: MethodCall,
        result: Result
    ) {
        val args = call.arguments as? Map<String, Any?>
        when (call.method) {
            "getPlatformVersion" -> result.success(handler.getPlatformVersion())
            "getSdkVersion" -> result.success(handler.getSdkVersion())
            "init" -> result.success(handler.init(args))
            "pay" -> result.success(handler.pay(args))
            "provideButton" -> result.success(handler.provideButton(args))
            "providePromotionalBannerWidget" -> result.success(handler.providePromotionalBannerWidget(args))
            "createController" -> result.success(handler.createController())
            "disposeController" -> result.success(handler.disposeController(args))
            "continueConfirmationFlow" -> result.success(handler.continueConfirmationFlow(args))
            "setOrderToken" -> result.success(handler.setOrderToken(args))
            "setSavePaymentMethodForMerchant" -> result.success(handler.setSavePaymentMethodForMerchant(args))
            else -> result.notImplemented()
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
        eventSink = null
    }
}
