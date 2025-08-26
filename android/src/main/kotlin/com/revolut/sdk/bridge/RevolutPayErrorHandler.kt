package com.revolut.sdk.bridge

import android.util.Log
import io.flutter.plugin.common.MethodChannel

/**
 * Comprehensive error handling and logging utility for Revolut Pay SDK integration
 * This class provides standardized error handling, logging, and error reporting
 */
class RevolutPayErrorHandler(
    private val methodChannel: MethodChannel,
    private val enableDebugLogging: Boolean = false
) {
    
    companion object {
        private const val TAG = "RevolutPaySDK"
        
        // Error codes
        const val ERROR_INITIALIZATION = "INITIALIZATION_ERROR"
        const val ERROR_PAYMENT = "PAYMENT_ERROR"
        const val ERROR_BUTTON_CREATION = "BUTTON_CREATION_ERROR"
        const val ERROR_BANNER_CREATION = "BANNER_CREATION_ERROR"
        const val ERROR_CONTROLLER = "CONTROLLER_ERROR"
        const val ERROR_VALIDATION = "VALIDATION_ERROR"
        const val ERROR_NETWORK = "NETWORK_ERROR"
        const val ERROR_PERMISSION = "PERMISSION_ERROR"
        const val ERROR_UNEXPECTED = "UNEXPECTED_ERROR"
        const val ERROR_SDK_NOT_READY = "SDK_NOT_READY_ERROR"
        const val ERROR_ACTIVITY_NOT_AVAILABLE = "ACTIVITY_NOT_AVAILABLE_ERROR"
        const val ERROR_INVALID_ARGUMENTS = "INVALID_ARGUMENTS_ERROR"
        const val ERROR_CONTROLLER_NOT_FOUND = "CONTROLLER_NOT_FOUND_ERROR"
        const val ERROR_ORDER_TOKEN = "ORDER_TOKEN_ERROR"
        const val ERROR_SAVE_PAYMENT_METHOD = "SAVE_PAYMENT_METHOD_ERROR"
        const val ERROR_CONFIRMATION_FLOW = "CONFIRMATION_FLOW_ERROR"
        
        // Error messages
        const val MSG_SDK_NOT_INITIALIZED = "Revolut Pay SDK not initialized"
        const val MSG_ACTIVITY_NOT_AVAILABLE = "Activity is not available"
        const val MSG_INVALID_ARGUMENTS = "Invalid arguments provided"
        const val MSG_CONTROLLER_NOT_FOUND = "Controller not found"
        const val MSG_NETWORK_ERROR = "Network error occurred"
        const val MSG_PERMISSION_DENIED = "Required permission denied"
        const val MSG_UNEXPECTED_ERROR = "An unexpected error occurred"
    }
    
    /**
     * Logs an error with appropriate level and sends it to Flutter
     */
    fun logAndReportError(
        errorCode: String,
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null,
        methodName: String? = null
    ) {
        // Log the error
        logError(errorCode, errorMessage, throwable, additionalData, methodName)
        
        // Send error to Flutter
        sendErrorToFlutter(errorCode, errorMessage, throwable, additionalData, methodName)
    }
    
    /**
     * Logs an error with appropriate level
     */
    private fun logError(
        errorCode: String,
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null,
        methodName: String? = null
    ) {
        val logMessage = buildString {
            append("Revolut Pay SDK Error: $errorCode")
            if (methodName != null) {
                append(" in $methodName")
            }
            append(" - $errorMessage")
            
            throwable?.let {
                append(" - Exception: ${it.javaClass.simpleName}: ${it.message}")
            }
            
            additionalData?.let { data ->
                append(" - Additional Data: $data")
            }
        }
        
        if (throwable != null) {
            Log.e(TAG, logMessage, throwable)
        } else {
            Log.e(TAG, logMessage)
        }
        
        // Debug logging if enabled
        if (enableDebugLogging) {
            Log.d(TAG, "Debug: $logMessage")
        }
    }
    
    /**
     * Sends error information to Flutter
     */
    private fun sendErrorToFlutter(
        errorCode: String,
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null,
        methodName: String? = null
    ) {
        val errorData = mutableMapOf<String, Any>()
        errorData["errorCode"] = errorCode
        errorData["errorMessage"] = errorMessage
        errorData["timestamp"] = System.currentTimeMillis()
        errorData["platform"] = "Android"
        
        throwable?.let {
            errorData["exceptionType"] = it.javaClass.simpleName
            errorData["exceptionMessage"] = it.message ?: "Unknown exception message"
            errorData["stackTrace"] = it.stackTraceToString()
        }
        
        methodName?.let { errorData["methodName"] = it }
        additionalData?.let { errorData.putAll(it) }
        
        try {
            methodChannel.invokeMethod("onError", errorData)
        } catch (e: Exception) {
            Log.e(TAG, "Failed to send error to Flutter", e)
        }
    }
    
    /**
     * Handles initialization errors
     */
    fun handleInitializationError(
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null
    ) {
        logAndReportError(
            ERROR_INITIALIZATION,
            errorMessage,
            throwable,
            additionalData,
            "init"
        )
    }
    
    /**
     * Handles payment errors
     */
    fun handlePaymentError(
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null
    ) {
        logAndReportError(
            ERROR_PAYMENT,
            errorMessage,
            throwable,
            additionalData,
            "pay"
        )
    }
    
    /**
     * Handles button creation errors
     */
    fun handleButtonCreationError(
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null
    ) {
        logAndReportError(
            ERROR_BUTTON_CREATION,
            errorMessage,
            throwable,
            additionalData,
            "provideButton"
        )
    }
    
    /**
     * Handles banner creation errors
     */
    fun handleBannerCreationError(
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null
    ) {
        logAndReportError(
            ERROR_BANNER_CREATION,
            errorMessage,
            throwable,
            additionalData,
            "providePromotionalBannerWidget"
        )
    }
    
    /**
     * Handles controller errors
     */
    fun handleControllerError(
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null
    ) {
        logAndReportError(
            ERROR_CONTROLLER,
            errorMessage,
            throwable,
            additionalData,
            "createController"
        )
    }
    
    /**
     * Handles validation errors
     */
    fun handleValidationError(
        errorMessage: String,
        fieldName: String? = null,
        additionalData: Map<String, Any>? = null
    ) {
        val enhancedData = additionalData?.toMutableMap() ?: mutableMapOf()
        fieldName?.let { enhancedData["fieldName"] = it }
        
        logAndReportError(
            ERROR_VALIDATION,
            errorMessage,
            null,
            enhancedData
        )
    }
    
    /**
     * Handles network errors
     */
    fun handleNetworkError(
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null
    ) {
        logAndReportError(
            ERROR_NETWORK,
            errorMessage,
            throwable,
            additionalData
        )
    }
    
    /**
     * Handles permission errors
     */
    fun handlePermissionError(
        permission: String,
        errorMessage: String,
        additionalData: Map<String, Any>? = null
    ) {
        val enhancedData = additionalData?.toMutableMap() ?: mutableMapOf()
        enhancedData["permission"] = permission
        
        logAndReportError(
            ERROR_PERMISSION,
            errorMessage,
            null,
            enhancedData
        )
    }
    
    /**
     * Handles unexpected errors
     */
    fun handleUnexpectedError(
        errorMessage: String,
        throwable: Throwable? = null,
        additionalData: Map<String, Any>? = null
    ) {
        logAndReportError(
            ERROR_UNEXPECTED,
            errorMessage,
            throwable,
            additionalData
        )
    }
    
    /**
     * Handles SDK not ready errors
     */
    fun handleSdkNotReadyError(methodName: String) {
        logAndReportError(
            ERROR_SDK_NOT_READY,
            MSG_SDK_NOT_INITIALIZED,
            null,
            mapOf("methodName" to methodName),
            methodName
        )
    }
    
    /**
     * Handles activity not available errors
     */
    fun handleActivityNotAvailableError(methodName: String) {
        logAndReportError(
            ERROR_ACTIVITY_NOT_AVAILABLE,
            MSG_ACTIVITY_NOT_AVAILABLE,
            null,
            mapOf("methodName" to methodName),
            methodName
        )
    }
    
    /**
     * Handles invalid arguments errors
     */
    fun handleInvalidArgumentsError(
        methodName: String,
        missingArguments: List<String>? = null,
        invalidArguments: Map<String, String>? = null
    ) {
        val additionalData = mutableMapOf<String, Any>()
        missingArguments?.let { additionalData["missingArguments"] = it }
        invalidArguments?.let { additionalData["invalidArguments"] = it }
        
        logAndReportError(
            ERROR_INVALID_ARGUMENTS,
            MSG_INVALID_ARGUMENTS,
            null,
            additionalData,
            methodName
        )
    }
    
    /**
     * Handles controller not found errors
     */
    fun handleControllerNotFoundError(controllerId: String, methodName: String) {
        logAndReportError(
            ERROR_CONTROLLER_NOT_FOUND,
            MSG_CONTROLLER_NOT_FOUND,
            null,
            mapOf("controllerId" to controllerId),
            methodName
        )
    }
    
    /**
     * Logs a warning message
     */
    fun logWarning(message: String, additionalData: Map<String, Any>? = null) {
        val logMessage = buildString {
            append("Revolut Pay SDK Warning: $message")
            additionalData?.let { append(" - Additional Data: $it") }
        }
        
        Log.w(TAG, logMessage)
        
        if (enableDebugLogging) {
            Log.d(TAG, "Debug Warning: $logMessage")
        }
    }
    
    /**
     * Logs an info message
     */
    fun logInfo(message: String, additionalData: Map<String, Any>? = null) {
        val logMessage = buildString {
            append("Revolut Pay SDK Info: $message")
            additionalData?.let { append(" - Additional Data: $it") }
        }
        
        Log.i(TAG, logMessage)
        
        if (enableDebugLogging) {
            Log.d(TAG, "Debug Info: $logMessage")
        }
    }
    
    /**
     * Logs a debug message (only if debug logging is enabled)
     */
    fun logDebug(message: String, additionalData: Map<String, Any>? = null) {
        if (enableDebugLogging) {
            val logMessage = buildString {
                append("Revolut Pay SDK Debug: $message")
                additionalData?.let { append(" - Additional Data: $it") }
            }
            
            Log.d(TAG, logMessage)
        }
    }
    
    /**
     * Creates a standardized error response for Flutter
     */
    fun createErrorResponse(
        errorCode: String,
        errorMessage: String,
        details: Any? = null
    ): Map<String, Any> {
        return mapOf(
            "success" to false,
            "errorCode" to errorCode,
            "errorMessage" to errorMessage,
            "details" to details,
            "timestamp" to System.currentTimeMillis(),
            "platform" to "Android"
        )
    }
    
    /**
     * Creates a standardized success response for Flutter
     */
    fun createSuccessResponse(data: Map<String, Any>? = null): Map<String, Any> {
        val response = mutableMapOf<String, Any>()
        response["success"] = true
        response["timestamp"] = System.currentTimeMillis()
        response["platform"] = "Android"
        
        data?.let { response.putAll(it) }
        
        return response
    }
}
