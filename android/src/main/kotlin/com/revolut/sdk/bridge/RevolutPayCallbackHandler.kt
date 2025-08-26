package com.revolut.sdk.bridge

import io.flutter.plugin.common.MethodChannel
import com.revolut.revolutpay.callback.OrderResultCallback
import com.revolut.revolutpay.controller.ConfirmationFlow

/**
 * Handles all Revolut Pay SDK callbacks and manages communication with Flutter
 * This class centralizes all callback logic and provides a clean interface
 * for the main plugin to communicate with Flutter
 */
class RevolutPayCallbackHandler(
    private val methodChannel: MethodChannel
) {
    
    /**
     * Creates an OrderResultCallback implementation that forwards events to Flutter
     */
    fun createOrderResultCallback(): OrderResultCallback {
        return object : OrderResultCallback {
            override fun onOrderCompleted() {
                methodChannel.invokeMethod("onOrderCompleted", mapOf(
                    "success" to true,
                    "timestamp" to System.currentTimeMillis()
                ))
            }

            override fun onOrderFailed(throwable: Throwable) {
                methodChannel.invokeMethod("onOrderFailed", mapOf(
                    "success" to false,
                    "error" to throwable.message,
                    "cause" to throwable.cause?.message,
                    "timestamp" to System.currentTimeMillis()
                ))
            }

            override fun onUserPaymentAbandoned() {
                methodChannel.invokeMethod("onUserPaymentAbandoned", mapOf(
                    "success" to false,
                    "reason" to "USER_ABANDONED",
                    "timestamp" to System.currentTimeMillis()
                ))
            }
        }
    }
    
    /**
     * Creates a click handler for the controller that manages confirmation flows
     */
    fun createClickHandler(): (ConfirmationFlow) -> Unit {
        return { confirmationFlow ->
            methodChannel.invokeMethod("onConfirmationFlowCreated", mapOf(
                "controllerId" to confirmationFlow.hashCode().toString(),
                "timestamp" to System.currentTimeMillis()
            ))
        }
    }
    
    /**
     * Sends a success response to Flutter
     */
    fun sendSuccess(methodName: String, data: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["success"] = true
        response["timestamp"] = System.currentTimeMillis()
        
        data?.let { response.putAll(it) }
        
        methodChannel.invokeMethod(methodName, response)
    }
    
    /**
     * Sends an error response to Flutter
     */
    fun sendError(methodName: String, errorCode: String, errorMessage: String, details: Any? = null) {
        val response = mapOf(
            "success" to false,
            "errorCode" to errorCode,
            "errorMessage" to errorMessage,
            "details" to details,
            "timestamp" to System.currentTimeMillis()
        )
        
        methodChannel.invokeMethod(methodName, response)
    }
    
    /**
     * Sends a payment status update to Flutter
     */
    fun sendPaymentStatusUpdate(status: String, orderId: String? = null, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["status"] = status
        response["timestamp"] = System.currentTimeMillis()
        
        orderId?.let { response["orderId"] = it }
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onPaymentStatusUpdate", response)
    }
    
    /**
     * Sends a button click event to Flutter
     */
    fun sendButtonClickEvent(buttonId: String, orderToken: String? = null) {
        val response = mapOf(
            "buttonId" to buttonId,
            "orderToken" to orderToken,
            "timestamp" to System.currentTimeMillis()
        )
        
        methodChannel.invokeMethod("onButtonClick", response)
    }
    
    /**
     * Sends a controller state change event to Flutter
     */
    fun sendControllerStateChange(controllerId: String, state: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["controllerId"] = controllerId
        response["state"] = state
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onControllerStateChange", response)
    }
    
    /**
     * Sends a promotional banner interaction event to Flutter
     */
    fun sendBannerInteraction(bannerId: String, interactionType: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["bannerId"] = bannerId
        response["interactionType"] = interactionType
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onBannerInteraction", response)
    }
    
    /**
     * Sends a lifecycle event to Flutter
     */
    fun sendLifecycleEvent(event: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["event"] = event
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onLifecycleEvent", response)
    }
    
    /**
     * Sends a deep link event to Flutter
     */
    fun sendDeepLinkEvent(uri: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["uri"] = uri
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onDeepLinkReceived", response)
    }
    
    /**
     * Sends a network status update to Flutter
     */
    fun sendNetworkStatusUpdate(isOnline: Boolean, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["isOnline"] = isOnline
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onNetworkStatusUpdate", response)
    }
    
    /**
     * Sends a configuration update event to Flutter
     */
    fun sendConfigurationUpdate(configType: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["configType"] = configType
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onConfigurationUpdate", response)
    }
    
    /**
     * Sends a debug log event to Flutter (useful for development)
     */
    fun sendDebugLog(level: String, message: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["level"] = level
        response["message"] = message
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onDebugLog", response)
    }
    
    /**
     * Sends a performance metric to Flutter
     */
    fun sendPerformanceMetric(metricName: String, value: Double, unit: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["metricName"] = metricName
        response["value"] = value
        response["unit"] = unit
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onPerformanceMetric", response)
    }
    
    /**
     * Sends a user interaction event to Flutter
     */
    fun sendUserInteraction(interactionType: String, elementId: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["interactionType"] = interactionType
        response["elementId"] = elementId
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onUserInteraction", response)
    }
    
    /**
     * Sends a session event to Flutter
     */
    fun sendSessionEvent(eventType: String, sessionId: String, additionalData: Map<String, Any>? = null) {
        val response = mutableMapOf<String, Any>()
        response["eventType"] = eventType
        response["sessionId"] = sessionId
        response["timestamp"] = System.currentTimeMillis()
        
        additionalData?.let { response.putAll(it) }
        
        methodChannel.invokeMethod("onSessionEvent", response)
    }
}
