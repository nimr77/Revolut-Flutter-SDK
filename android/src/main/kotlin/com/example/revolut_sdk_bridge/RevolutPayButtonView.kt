package com.example.revolut_sdk_bridge

import android.content.Context
import android.graphics.Color
import android.util.Log
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import io.flutter.plugin.common.BinaryMessenger
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.platform.PlatformView
import org.json.JSONObject

class RevolutPayButtonView(
    context: Context,
    id: Int,
    creationParams: Map<String, Any?>?,
    private val logChannel: MethodChannel?,
    private val emitEvent: ((Map<String, Any>) -> Unit)?,
) : PlatformView {
    private val logTag = "RevolutPayButtonView"
    private val container: FrameLayout = FrameLayout(context)

    init {
        setupView(context, creationParams)
    }

    private fun setupView(context: Context, creationParams: Map<String, Any?>?) {
        container.setBackgroundColor(Color.TRANSPARENT)
        val label = TextView(context)
        label.text = "Revolut Pay"
        label.setTextColor(Color.WHITE)
        label.textSize = 16f

        val button = FrameLayout(context)
        button.setBackgroundColor(Color.parseColor("#000000"))
        val padding = (16 * context.resources.displayMetrics.density).toInt()
        button.setPadding(padding, padding, padding, padding)

        val lp = FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.MATCH_PARENT,
            FrameLayout.LayoutParams.MATCH_PARENT,
        )
        button.addView(label, FrameLayout.LayoutParams(
            FrameLayout.LayoutParams.WRAP_CONTENT,
            FrameLayout.LayoutParams.WRAP_CONTENT,
        ))
        container.addView(button, lp)

        val orderToken = creationParams?.get("orderToken") as? String
        val buttonParams = creationParams?.get("buttonParams") as? Map<*, *>
        Log.i(logTag, "Created RevolutPayButtonView with orderToken=$orderToken params=$buttonParams")

        button.isClickable = true
        button.setOnClickListener {
            try {
                emitEvent?.invoke(
                    mapOf(
                        "method" to "onButtonClick",
                        "data" to mapOf(
                            "orderToken" to (orderToken ?: ""),
                            "source" to "android_view",
                        ),
                    ),
                )
            } catch (t: Throwable) {
                Log.w(logTag, "Failed to emit onButtonClick: ${t.message}")
            }
        }
    }

    override fun getView(): View = container

    override fun dispose() {
        // nothing to dispose
    }
}

class RevolutPayButtonFactory(
    private val messenger: BinaryMessenger,
    private val emitEvent: ((Map<String, Any>) -> Unit)?,
) : io.flutter.plugin.platform.PlatformViewFactory(io.flutter.plugin.common.StandardMessageCodec.INSTANCE) {

    private val logChannel: MethodChannel? = try {
        MethodChannel(messenger, "revolut_sdk_bridge_logs")
    } catch (_: Throwable) { null }

    override fun create(context: Context, id: Int, args: Any?): PlatformView {
        val creationParams = (args as? Map<String, Any?>)
        return RevolutPayButtonView(context, id, creationParams, logChannel, emitEvent)
    }
}


