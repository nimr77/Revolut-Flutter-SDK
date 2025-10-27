package com.example.revolut_sdk_bridge

import android.util.Log
import java.util.UUID
// Revolut SDK (added; guard actual usage at runtime based on dependency availability)
// If the dependency is not present yet, the configure() call will be skipped gracefully
// Replace with the concrete imports once the dependency is available in Gradle
// import com.revolut.payments.RevolutPaymentsSDK

/**
 * Clean handler for MethodChannel calls. Each method logs inputs and
 * returns a stubbed response so Flutter side can integrate end-to-end.
 */
class RevolutBridgeHandler {
    private val logTag = "RevolutSdkBridge"
    private var isConfigured: Boolean = false

    // Lightweight in-memory controller store to support the confirmation flow API
    private val controllerStateById: MutableMap<String, MutableMap<String, Any?>> = mutableMapOf()

    // Event emitter provided by the plugin (EventChannel.success)
    private var eventEmitter: ((Map<String, Any>) -> Unit)? = null

    fun setEventEmitter(emitter: ((Map<String, Any>) -> Unit)?) {
        eventEmitter = emitter
    }

    private fun sendEvent(method: String, data: Map<String, Any>) {
        try {
            eventEmitter?.invoke(
                mapOf(
                    "method" to method,
                    "data" to data,
                ),
            )
        } catch (t: Throwable) {
            Log.w(logTag, "Failed to emit event: $method - ${t.message}")
        }
    }

    fun getPlatformVersion(): String {
        Log.i(logTag, "getPlatformVersion()")
        return "Android ${android.os.Build.VERSION.RELEASE}"
    }

    fun getSdkVersion(): Map<String, Any> {
        Log.i(logTag, "getSdkVersion()")
        return mapOf(
            "name" to "revolut_sdk_bridge",
            // The Android SDK version is not directly retrievable without the dependency;
            // the plugin version is returned instead. Update when SDK exposes a runtime API.
            "version" to "android-bridge-0.1.0",
            "platform" to "android",
        )
    }

    fun init(args: Map<String, Any?>?): Boolean {
        Log.i(logTag, "init(args=$args)")

        val environment = (args?.get("environment") as? String)?.uppercase() ?: "SANDBOX"
        val merchantPublicKey = (args?.get("merchantPublicKey") as? String).orEmpty()

        if (merchantPublicKey.isEmpty()) {
            Log.w(logTag, "init() missing merchantPublicKey")
            return false
        }

        // Best-effort configure; do not crash if SDK is not on classpath yet
        try {
            val env = when (environment) {
                "MAIN", "PRODUCTION", "PROD" ->
                    Class.forName("com.revolut.payments.RevolutPaymentsSDK\$Environment")
                        .getField("PRODUCTION").get(null)
                else ->
                    Class.forName("com.revolut.payments.RevolutPaymentsSDK\$Environment")
                        .getField("SANDBOX").get(null)
            }

            val sdkClass = Class.forName("com.revolut.payments.RevolutPaymentsSDK")
            val configClass = Class.forName("com.revolut.payments.RevolutPaymentsSDK\$Configuration")

            val config = configClass.getConstructor(env.javaClass, String::class.java)
                .newInstance(env, merchantPublicKey)

            val configure = sdkClass.getMethod("configure", configClass)
            configure.invoke(null, config)

            isConfigured = true
            sendEvent(
                "onConfigurationUpdate",
                mapOf(
                    "environment" to environment,
                    "merchantPublicKeySet" to true,
                ),
            )
            return true
        } catch (t: Throwable) {
            // Fallback: mark configured to allow end-to-end testing
            Log.w(logTag, "Revolut SDK configure() not executed: ${t.message}. Proceeding in fallback mode.")
            isConfigured = true
            return true
        }
    }

    fun pay(args: Map<String, Any?>?): Boolean {
        Log.i(logTag, "pay(args=$args)")
        val orderToken = (args?.get("orderToken") as? String).orEmpty()
        val saveForMerchant = args?.get("savePaymentMethodForMerchant") as? Boolean ?: false

        if (!isConfigured) {
            Log.w(logTag, "pay() called before init()")
            return false
        }

        if (orderToken.isEmpty()) {
            Log.w(logTag, "pay() missing orderToken")
            return false
        }

        // For now, emit a status event so Flutter integration can proceed.
        // Replace this block with actual SDK invocation when Activity/Lifecycle is available.
        sendEvent(
            "onPaymentStatusUpdate",
            mapOf(
                "status" to "initiated",
                "orderToken" to orderToken,
                "savePaymentMethodForMerchant" to saveForMerchant,
            ),
        )

        // Simulate immediate completion to keep UX flowing while wiring the real SDK
        sendEvent(
            "onOrderCompleted",
            mapOf(
                "orderToken" to orderToken,
                "status" to "completed",
                "platform" to "android",
            ),
        )
        return true
    }

    fun provideButton(args: Map<String, Any?>?): Map<String, Any> {
        Log.i(logTag, "provideButton(args=$args)")
        // In a full implementation, a PlatformView renders the native button.
        // Here we just return an identifier acknowledging it was requested.
        val buttonId = "btn_${UUID.randomUUID()}"
        return mapOf(
            "buttonId" to buttonId,
            "success" to true,
        )
    }

    fun providePromotionalBannerWidget(args: Map<String, Any?>?): Map<String, Any> {
        Log.i(logTag, "providePromotionalBannerWidget(args=$args)")
        return mapOf(
            "bannerId" to "banner_stub",
            "success" to true,
        )
    }

    fun createController(): Map<String, Any> {
        Log.i(logTag, "createController()")
        val controllerId = "ctrl_${UUID.randomUUID()}"
        controllerStateById[controllerId] = mutableMapOf(
            "orderToken" to null,
            "savePaymentMethodForMerchant" to false,
            "active" to true,
        )
        return mapOf(
            "controllerId" to controllerId,
            "success" to true,
        )
    }

    fun disposeController(args: Map<String, Any?>?): Boolean {
        Log.i(logTag, "disposeController(args=$args)")
        val controllerId = args?.get("controllerId") as? String ?: return false
        controllerStateById.remove(controllerId)
        sendEvent(
            "onControllerStateChange",
            mapOf(
                "controllerId" to controllerId,
                "state" to "disposed",
            ),
        )
        return true
    }

    fun continueConfirmationFlow(args: Map<String, Any?>?): Boolean {
        Log.i(logTag, "continueConfirmationFlow(args=$args)")
        val controllerId = args?.get("controllerId") as? String ?: return false
        val state = controllerStateById[controllerId] ?: return false
        val orderToken = state["orderToken"] as? String ?: return false
        val saveForMerchant = state["savePaymentMethodForMerchant"] as? Boolean ?: false

        // Here, integrate with Revolut SDK using Activity/Lifecycle when available.
        sendEvent(
            "onPaymentStatusUpdate",
            mapOf(
                "status" to "confirmation_continued",
                "orderToken" to orderToken,
                "controllerId" to controllerId,
                "savePaymentMethodForMerchant" to saveForMerchant,
            ),
        )
        return true
    }

    fun setOrderToken(args: Map<String, Any?>?): Boolean {
        Log.i(logTag, "setOrderToken(args=$args)")
        val controllerId = args?.get("controllerId") as? String ?: return false
        val token = args["orderToken"] as? String ?: return false
        val state = controllerStateById[controllerId] ?: return false
        state["orderToken"] = token
        sendEvent(
            "onControllerStateChange",
            mapOf(
                "controllerId" to controllerId,
                "state" to "order_token_set",
            ),
        )
        return true
    }

    fun setSavePaymentMethodForMerchant(args: Map<String, Any?>?): Boolean {
        Log.i(logTag, "setSavePaymentMethodForMerchant(args=$args)")
        val controllerId = args?.get("controllerId") as? String ?: return false
        val save = args["savePaymentMethodForMerchant"] as? Boolean ?: false
        val state = controllerStateById[controllerId] ?: return false
        state["savePaymentMethodForMerchant"] = save
        sendEvent(
            "onControllerStateChange",
            mapOf(
                "controllerId" to controllerId,
                "state" to "save_method_flag_set",
                "savePaymentMethodForMerchant" to save,
            ),
        )
        return true
    }
}


