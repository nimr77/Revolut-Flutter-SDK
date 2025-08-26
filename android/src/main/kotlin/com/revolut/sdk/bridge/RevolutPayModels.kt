package com.revolut.sdk.bridge

import com.revolut.revolutpay.ui.button.ButtonParams
import com.revolut.revolutpay.ui.button.VariantModes
import com.revolut.revolutpay.ui.promotional.PromoBannerParams
import com.revolut.revolutpay.model.Customer
import com.revolut.revolutpay.model.DateOfBirth
import com.revolut.revolutpay.model.Country

/**
 * Data models and enums for Revolut Pay SDK integration
 * This file contains all the necessary data structures that Flutter can use
 * to communicate with the native Revolut Pay SDK
 */

// Environment enum for SDK initialization
enum class RevolutEnvironment(val value: String) {
    MAIN("MAIN"),
    SANDBOX("SANDBOX")
}

// Button radius options
enum class ButtonRadius(val value: String) {
    SMALL("SMALL"),
    MEDIUM("MEDIUM"),
    LARGE("LARGE")
}

// Button size options
enum class ButtonSize(val value: String) {
    SMALL("SMALL"),
    MEDIUM("MEDIUM"),
    LARGE("LARGE")
}

// Box text options for button customization
enum class BoxText(val value: String) {
    NONE("NONE"),
    GET_CASHBACK_VALUE("GET_CASHBACK_VALUE"),
    GET_CASHBACK_PERCENTAGE("GET_CASHBACK_PERCENTAGE")
}

// Button variant options
enum class ButtonVariant(val value: String) {
    LIGHT("LIGHT"),
    DARK("DARK")
}

// Customer data structure
data class CustomerData(
    val name: String? = null,
    val email: String? = null,
    val phone: String? = null,
    val dateOfBirth: DateOfBirthData? = null,
    val country: CountryData? = null
)

// Date of birth data structure
data class DateOfBirthData(
    val day: Int,
    val month: Int,
    val year: Int
)

// Country data structure
data class CountryData(
    val value: String // ISO 3166 2-letter country code
)

// Button parameters data structure
data class ButtonParamsData(
    val radius: ButtonRadius = ButtonRadius.MEDIUM,
    val size: ButtonSize = ButtonSize.LARGE,
    val boxText: BoxText = BoxText.NONE,
    val boxTextCurrency: String? = null,
    val variantModes: VariantModesData? = null
)

// Variant modes data structure
data class VariantModesData(
    val darkTheme: ButtonVariant = ButtonVariant.DARK,
    val lightTheme: ButtonVariant = ButtonVariant.LIGHT
)

// Promotional banner parameters data structure
data class PromoBannerParamsData(
    // Add specific promotional banner parameters as needed
    val customParam: String? = null
)

// Order result callback data
data class OrderResultData(
    val success: Boolean,
    val orderId: String? = null,
    val error: String? = null,
    val cause: String? = null
)

// Controller creation result data
data class ControllerResultData(
    val controllerId: String,
    val success: Boolean
)

// Button creation result data
data class ButtonResultData(
    val buttonId: String,
    val success: Boolean
)

// Banner creation result data
data class BannerResultData(
    val bannerId: String,
    val success: Boolean
)

// Payment flow data
data class PaymentFlowData(
    val orderToken: String,
    val savePaymentMethodForMerchant: Boolean = false
)

// SDK initialization data
data class SdkInitData(
    val environment: RevolutEnvironment,
    val returnUri: String,
    val merchantPublicKey: String,
    val requestShipping: Boolean = false,
    val customer: CustomerData? = null
)

/**
 * Extension functions to convert between Flutter data and SDK objects
 */

fun CustomerData.toSdkCustomer(): Customer {
    return Customer(
        name = this.name,
        email = this.email,
        phone = this.phone,
        dateOfBirth = this.dateOfBirth?.toSdkDateOfBirth(),
        country = this.country?.toSdkCountry()
    )
}

fun DateOfBirthData.toSdkDateOfBirth(): DateOfBirth {
    return DateOfBirth(
        day = this.day,
        month = this.month,
        year = this.year
    )
}

fun CountryData.toSdkCountry(): Country {
    return Country(this.value)
}

fun ButtonParamsData.toSdkButtonParams(): ButtonParams {
    return ButtonParams.Builder()
        .radius(this.radius.toSdkRadius())
        .size(this.size.toSdkSize())
        .boxText(this.boxText.toSdkBoxText())
        .boxTextCurrency(this.boxTextCurrency)
        .variantModes(this.variantModes?.toSdkVariantModes())
        .build()
}

fun ButtonRadius.toSdkRadius(): ButtonParams.Radius {
    return when (this) {
        ButtonRadius.SMALL -> ButtonParams.Radius.SMALL
        ButtonRadius.LARGE -> ButtonParams.Radius.LARGE
        else -> ButtonParams.Radius.MEDIUM
    }
}

fun ButtonSize.toSdkSize(): ButtonParams.Size {
    return when (this) {
        ButtonSize.SMALL -> ButtonParams.Size.SMALL
        ButtonSize.MEDIUM -> ButtonParams.Size.MEDIUM
        else -> ButtonParams.Size.LARGE
    }
}

fun BoxText.toSdkBoxText(): ButtonParams.BoxText {
    return when (this) {
        BoxText.GET_CASHBACK_VALUE -> ButtonParams.BoxText.GET_CASHBACK_VALUE
        BoxText.GET_CASHBACK_PERCENTAGE -> ButtonParams.BoxText.GET_CASHBACK_PERCENTAGE
        else -> ButtonParams.BoxText.NONE
    }
}

fun VariantModesData.toSdkVariantModes(): VariantModes {
    return VariantModes(
        darkTheme = this.darkTheme.toSdkVariant(),
        lightTheme = this.lightTheme.toSdkVariant()
    )
}

fun ButtonVariant.toSdkVariant(): ButtonParams.Variant {
    return when (this) {
        ButtonVariant.DARK -> ButtonParams.Variant.DARK
        else -> ButtonParams.Variant.LIGHT
    }
}

fun PromoBannerParamsData.toSdkPromoBannerParams(): PromoBannerParams {
    return PromoBannerParams.Builder()
        .build()
}

/**
 * Utility functions for data validation
 */
object RevolutPayDataValidator {
    
    fun validateCustomerData(customer: CustomerData?): Boolean {
        if (customer == null) return true
        
        // Validate email format if provided
        customer.email?.let { email ->
            if (!android.util.Patterns.EMAIL_ADDRESS.matcher(email).matches()) {
                return false
            }
        }
        
        // Validate phone format if provided
        customer.phone?.let { phone ->
            if (!phone.startsWith("+") || phone.length < 10) {
                return false
            }
        }
        
        // Validate date of birth if provided
        customer.dateOfBirth?.let { dob ->
            if (dob.day < 1 || dob.day > 31 || dob.month < 1 || dob.month > 12 || dob.year < 1900 || dob.year > 2100) {
                return false
            }
        }
        
        // Validate country if provided
        customer.country?.let { country ->
            if (country.value.length != 2 || !country.value.all { it.isUpperCase() }) {
                return false
            }
        }
        
        return true
    }
    
    fun validateButtonParams(params: ButtonParamsData): Boolean {
        // Validate currency format if provided
        params.boxTextCurrency?.let { currency ->
            if (currency.length != 3 || !currency.all { it.isUpperCase() }) {
                return false
            }
        }
        
        return true
    }
    
    fun validateSdkInitData(data: SdkInitData): Boolean {
        // Validate return URI format
        if (!data.returnUri.startsWith("http://") && !data.returnUri.startsWith("https://")) {
            return false
        }
        
        // Validate merchant public key (should be non-empty)
        if (data.merchantPublicKey.isBlank()) {
            return false
        }
        
        return true
    }
}
