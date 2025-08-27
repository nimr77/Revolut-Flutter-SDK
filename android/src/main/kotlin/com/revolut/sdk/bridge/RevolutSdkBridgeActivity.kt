package com.revolut.sdk.bridge

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import android.util.Log

/**
 * Activity to handle deep link returns from Revolut Pay payments.
 * This activity must have launchMode="singleTop" to ensure the existing
 * activity instance receives the result instead of creating a new one.
 */
class RevolutSdkBridgeActivity : Activity() {
    
    companion object {
        private const val TAG = "RevolutSdkBridgeActivity"
    }
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Handle the deep link intent
        handleIntent(intent)
        
        // Close this activity as it's only needed for deep link handling
        finish()
    }
    
    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        
        // Handle new intents (when activity is already running)
        handleIntent(intent)
    }
    
    private fun handleIntent(intent: Intent?) {
        intent?.let { incomingIntent ->
            Log.d(TAG, "Handling deep link intent: ${incomingIntent.data}")
            
            // Extract payment result data from the deep link
            val data = incomingIntent.data
            if (data != null) {
                // Parse the deep link data to extract payment status
                val paymentStatus = data.getQueryParameter("status")
                val orderId = data.getQueryParameter("orderId")
                val errorCode = data.getQueryParameter("errorCode")
                val errorMessage = data.getQueryParameter("errorMessage")
                
                Log.d(TAG, "Payment result - Status: $paymentStatus, OrderId: $orderId, Error: $errorCode")
                
                // Send the payment result back to the Flutter side via the plugin
                // The plugin will handle this through the event channel
                sendPaymentResultToFlutter(paymentStatus, orderId, errorCode, errorMessage)
            }
        }
    }
    
    private fun sendPaymentResultToFlutter(
        status: String?,
        orderId: String?,
        errorCode: String?,
        errorMessage: String?
    ) {
        // This will be handled by the main plugin through the event channel
        // The activity is just a bridge for the deep link
        Log.d(TAG, "Payment result processed - forwarding to Flutter")
    }
}

