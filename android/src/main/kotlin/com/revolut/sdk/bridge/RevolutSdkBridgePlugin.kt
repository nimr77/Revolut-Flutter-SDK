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
import android.content.Context
import android.net.Uri
import androidx.annotation.NonNull

class RevolutSdkBridgePlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private var activityBinding: ActivityPluginBinding? = null

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge")
        channel.setMethodCallHandler(this)
        context = flutterPluginBinding.applicationContext
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        when (call.method) {
            "init" -> handleInit(call, result)
            "getSdkVersion" -> handleGetSdkVersion(call, result)
            "getPlatformVersion" -> handleGetPlatformVersion(call, result)
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

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
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
