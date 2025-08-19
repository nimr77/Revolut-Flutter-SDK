package com.revolut.sdk.bridge

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import android.app.Activity
import android.content.Intent
import android.net.Uri
import com.revolut.sdk.RevolutSDK
import com.revolut.sdk.RevolutSDKConfig
import com.revolut.sdk.auth.RevolutAuth
import com.revolut.sdk.auth.RevolutAuthConfig
import com.revolut.sdk.models.*
import com.revolut.sdk.callbacks.*
import org.json.JSONObject
import org.json.JSONArray
import java.util.*

/** RevolutSdkBridgePlugin */
class RevolutSdkBridgePlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware {
    
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null
    private var revolutSDK: RevolutSDK? = null
    private var revolutAuth: RevolutAuth? = null
    private var isInitialized = false

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "revolut_sdk_bridge")
        channel.setMethodCallHandler(this)
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

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "isInitialized" -> handleIsInitialized(result)
            "startOAuthFlow" -> handleStartOAuthFlow(call, result)
            "handleOAuthCallback" -> handleOAuthCallback(call, result)
            "getUserProfile" -> handleGetUserProfile(result)
            "getUserAccounts" -> handleGetUserAccounts(result)
            "getAccountDetails" -> handleGetAccountDetails(call, result)
            "getAccountTransactions" -> handleGetAccountTransactions(call, result)
            "createPayment" -> handleCreatePayment(call, result)
            "getPaymentStatus" -> handleGetPaymentStatus(call, result)
            "getExchangeRates" -> handleGetExchangeRates(call, result)
            "performExchange" -> handlePerformExchange(call, result)
            "logout" -> handleLogout(result)
            "getPlatformVersion" -> handleGetPlatformVersion(result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: Result) {
        try {
            val clientId = call.argument<String>("clientId")
            val clientSecret = call.argument<String>("clientSecret")
            val redirectUri = call.argument<String>("redirectUri")
            val environment = call.argument<String>("environment") ?: "sandbox"

            if (clientId == null || clientSecret == null || redirectUri == null) {
                result.error("INVALID_ARGUMENTS", "Missing required parameters", null)
                return
            }

            // Initialize Revolut SDK
            val config = RevolutSDKConfig.Builder()
                .clientId(clientId)
                .clientSecret(clientSecret)
                .redirectUri(redirectUri)
                .environment(if (environment == "production") "production" else "sandbox")
                .build()

            revolutSDK = RevolutSDK.initialize(config)
            
            // Initialize Revolut Auth
            val authConfig = RevolutAuthConfig.Builder()
                .clientId(clientId)
                .clientSecret(clientSecret)
                .redirectUri(redirectUri)
                .build()
            
            revolutAuth = RevolutAuth.initialize(authConfig)
            
            isInitialized = true
            result.success(true)
        } catch (e: Exception) {
            result.error("INITIALIZATION_ERROR", e.message, null)
        }
    }

    private fun handleIsInitialized(result: Result) {
        result.success(isInitialized)
    }

    private fun handleStartOAuthFlow(call: MethodCall, result: Result) {
        if (!isInitialized || revolutAuth == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        try {
            val scopes = call.argument<List<String>>("scopes") ?: listOf("read", "write")
            val state = call.argument<String>("state") ?: UUID.randomUUID().toString()

            val authUrl = revolutAuth!!.getAuthorizationUrl(scopes, state)
            result.success(authUrl)
        } catch (e: Exception) {
            result.error("OAUTH_ERROR", e.message, null)
        }
    }

    private fun handleOAuthCallback(call: MethodCall, result: Result) {
        if (!isInitialized || revolutAuth == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        try {
            val url = call.argument<String>("url")
            if (url == null) {
                result.error("INVALID_ARGUMENTS", "URL is required", null)
                return
            }

            val uri = Uri.parse(url)
            val code = uri.getQueryParameter("code")
            val state = uri.getQueryParameter("state")

            if (code != null) {
                revolutAuth!!.exchangeCodeForToken(code, object : TokenCallback {
                    override fun onSuccess(token: String) {
                        val response = mapOf(
                            "success" to true,
                            "token" to token,
                            "state" to state
                        )
                        result.success(response)
                    }

                    override fun onError(error: String) {
                        result.error("TOKEN_EXCHANGE_ERROR", error, null)
                    }
                })
            } else {
                result.error("INVALID_CALLBACK", "No authorization code found", null)
            }
        } catch (e: Exception) {
            result.error("CALLBACK_ERROR", e.message, null)
        }
    }

    private fun handleGetUserProfile(result: Result) {
        if (!isInitialized || revolutSDK == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        revolutSDK!!.getUserProfile(object : UserProfileCallback {
            override fun onSuccess(profile: UserProfile) {
                val response = mapOf(
                    "id" to profile.id,
                    "firstName" to profile.firstName,
                    "lastName" to profile.lastName,
                    "email" to profile.email,
                    "phone" to profile.phone
                )
                result.success(response)
            }

            override fun onError(error: String) {
                result.error("PROFILE_ERROR", error, null)
            }
        })
    }

    private fun handleGetUserAccounts(result: Result) {
        if (!isInitialized || revolutSDK == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        revolutSDK!!.getAccounts(object : AccountsCallback {
            override fun onSuccess(accounts: List<Account>) {
                val accountsList = accounts.map { account ->
                    mapOf(
                        "id" to account.id,
                        "name" to account.name,
                        "currency" to account.currency,
                        "balance" to account.balance,
                        "type" to account.type
                    )
                }
                result.success(accountsList)
            }

            override fun onError(error: String) {
                result.error("ACCOUNTS_ERROR", error, null)
            }
        })
    }

    private fun handleGetAccountDetails(call: MethodCall, result: Result) {
        if (!isInitialized || revolutSDK == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        val accountId = call.argument<String>("accountId")
        if (accountId == null) {
            result.error("INVALID_ARGUMENTS", "Account ID is required", null)
            return
        }

        revolutSDK!!.getAccountDetails(accountId, object : AccountDetailsCallback {
            override fun onSuccess(account: Account) {
                val response = mapOf(
                    "id" to account.id,
                    "name" to account.name,
                    "currency" to account.currency,
                    "balance" to account.balance,
                    "type" to account.type,
                    "iban" to account.iban,
                    "bic" to account.bic
                )
                result.success(response)
            }

            override fun onError(error: String) {
                result.error("ACCOUNT_DETAILS_ERROR", error, null)
            }
        })
    }

    private fun handleGetAccountTransactions(call: MethodCall, result: Result) {
        if (!isInitialized || revolutSDK == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        val accountId = call.argument<String>("accountId")
        if (accountId == null) {
            result.error("INVALID_ARGUMENTS", "Account ID is required", null)
            return
        }

        val from = call.argument<String>("from")
        val to = call.argument<String>("to")
        val limit = call.argument<Int>("limit") ?: 50

        revolutSDK!!.getTransactions(accountId, from, to, limit, object : TransactionsCallback {
            override fun onSuccess(transactions: List<Transaction>) {
                val transactionsList = transactions.map { transaction ->
                    mapOf(
                        "id" to transaction.id,
                        "amount" to transaction.amount,
                        "currency" to transaction.currency,
                        "description" to transaction.description,
                        "date" to transaction.date,
                        "type" to transaction.type,
                        "status" to transaction.status
                    )
                }
                result.success(transactionsList)
            }

            override fun onError(error: String) {
                result.error("TRANSACTIONS_ERROR", error, null)
            }
        })
    }

    private fun handleCreatePayment(call: MethodCall, result: Result) {
        if (!isInitialized || revolutSDK == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        val accountId = call.argument<String>("accountId")
        val recipientAccountId = call.argument<String>("recipientAccountId")
        val amount = call.argument<Double>("amount")
        val currency = call.argument<String>("currency")
        val reference = call.argument<String>("reference")

        if (accountId == null || recipientAccountId == null || amount == null || currency == null) {
            result.error("INVALID_ARGUMENTS", "Missing required parameters", null)
            return
        }

        revolutSDK!!.createPayment(accountId, recipientAccountId, amount, currency, reference, object : PaymentCallback {
            override fun onSuccess(payment: Payment) {
                val response = mapOf(
                    "id" to payment.id,
                    "status" to payment.status,
                    "amount" to payment.amount,
                    "currency" to payment.currency,
                    "reference" to payment.reference
                )
                result.success(response)
            }

            override fun onError(error: String) {
                result.error("PAYMENT_ERROR", error, null)
            }
        })
    }

    private fun handleGetPaymentStatus(call: MethodCall, result: Result) {
        if (!isInitialized || revolutSDK == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        val paymentId = call.argument<String>("paymentId")
        if (paymentId == null) {
            result.error("INVALID_ARGUMENTS", "Payment ID is required", null)
            return
        }

        revolutSDK!!.getPaymentStatus(paymentId, object : PaymentStatusCallback {
            override fun onSuccess(status: String) {
                result.success(mapOf("status" to status))
            }

            override fun onError(error: String) {
                result.error("PAYMENT_STATUS_ERROR", error, null)
            }
        })
    }

    private fun handleGetExchangeRates(call: MethodCall, result: Result) {
        if (!isInitialized || revolutSDK == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        val fromCurrency = call.argument<String>("fromCurrency")
        val toCurrency = call.argument<String>("toCurrency")

        revolutSDK!!.getExchangeRates(fromCurrency, toCurrency, object : ExchangeRatesCallback {
            override fun onSuccess(rates: Map<String, Double>) {
                result.success(rates)
            }

            override fun onError(error: String) {
                result.error("EXCHANGE_RATES_ERROR", error, null)
            }
        })
    }

    private fun handlePerformExchange(call: MethodCall, result: Result) {
        if (!isInitialized || revolutSDK == null) {
            result.error("NOT_INITIALIZED", "Revolut SDK not initialized", null)
            return
        }

        val fromAccountId = call.argument<String>("fromAccountId")
        val toAccountId = call.argument<String>("toAccountId")
        val amount = call.argument<Double>("amount")
        val fromCurrency = call.argument<String>("fromCurrency")
        val toCurrency = call.argument<String>("toCurrency")

        if (fromAccountId == null || toAccountId == null || amount == null || fromCurrency == null || toCurrency == null) {
            result.error("INVALID_ARGUMENTS", "Missing required parameters", null)
            return
        }

        revolutSDK!!.performExchange(fromAccountId, toAccountId, amount, fromCurrency, toCurrency, object : ExchangeCallback {
            override fun onSuccess(exchange: Exchange) {
                val response = mapOf(
                    "id" to exchange.id,
                    "status" to exchange.status,
                    "amount" to exchange.amount,
                    "fromCurrency" to exchange.fromCurrency,
                    "toCurrency" to exchange.toCurrency,
                    "rate" to exchange.rate
                )
                result.success(response)
            }

            override fun onError(error: String) {
                result.error("EXCHANGE_ERROR", error, null)
            }
        })
    }

    private fun handleLogout(result: Result) {
        try {
            revolutSDK?.logout()
            revolutAuth?.logout()
            isInitialized = false
            result.success(true)
        } catch (e: Exception) {
            result.error("LOGOUT_ERROR", e.message, null)
        }
    }

    private fun handleGetPlatformVersion(result: Result) {
        result.success("Android ${android.os.Build.VERSION.RELEASE}")
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
