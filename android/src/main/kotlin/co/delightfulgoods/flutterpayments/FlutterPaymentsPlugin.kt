package co.delightfulgoods.flutterpayments

import android.app.Activity
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClient.BillingResponse
import com.android.billingclient.api.BillingClient.BillingResponse.*
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.SkuDetailsParams
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry.Registrar
import java.util.*
import kotlin.concurrent.schedule


@Suppress("unused")
class FlutterPaymentsPlugin(var activity: Activity) : MethodCallHandler {
    companion object {
        @JvmStatic
        fun registerWith(registrar: Registrar) {
            val channel = MethodChannel(registrar.messenger(), "co.delightfulgoods.flutterpayments")
            channel.setMethodCallHandler(FlutterPaymentsPlugin(activity = registrar.activity()))
        }
    }

    private val purchaseHistoryListener = PurchaseHistoryListener()
    private var billingClient: BillingClient =
            BillingClient.newBuilder(this.activity).setListener(purchaseHistoryListener).build()

    private var billingIsAvailable: Boolean = false

    private val clientStateListener = object : BillingClientStateListener {
        override fun onBillingServiceDisconnected() = retryBillingConnection()

        override fun onBillingSetupFinished(@BillingResponse billingResponseCode: Int) {
            when (billingResponseCode) {
                BILLING_UNAVAILABLE, SERVICE_UNAVAILABLE -> retryBillingConnection()
                OK -> billingIsAvailable = true
            }
        }
    }

    init {
        billingClient.startConnection(clientStateListener)
    }

    private fun retryBillingConnection() {
        billingIsAvailable = false

        Timer("retryBillingConnection", false).schedule(3000) {
            billingClient.startConnection(clientStateListener)
        }
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        if (!billingIsAvailable && call.method != "billingEnabled") {
            return result.error("UNAVAILABLE", "Billing is not available.", null)
        }

        when (call.method) {
            "getPurchaseHistory" -> getPurchaseHistory(result, strToSkuType(call.argument("productType")))
            "getProducts" -> getProducts(result, call.argument("skus"), strToSkuType(call.argument("productType")))
            "purchase" -> purchase(result, call.argument("sku"), strToSkuType(call.argument("productType")))
            "modifySubscription" -> modifySubscription(result, call.argument("oldSku"), call.argument("newSku"))
            "billingEnabled" -> result.success(billingIsAvailable)
            else -> result.notImplemented()
        }

    }

    private fun modifySubscription(result: Result, oldSku: String, newSku: String) {
        val flowParams = BillingFlowParams.newBuilder()
                .setOldSku(oldSku)
                .setSku(newSku)
                .setType(BillingClient.SkuType.SUBS)
                .build()

        launchBillingFlow(flowParams, result)
    }

    private fun purchase(result: Result, sku: String, skuType: String) {
        val flowParams = BillingFlowParams.newBuilder()
                .setSku(sku)
                .setType(skuType)
                .build()

        launchBillingFlow(flowParams, result)
    }

    private fun launchBillingFlow(flowParams: BillingFlowParams?, result: Result) {
        val responseCode = billingClient.launchBillingFlow(activity, flowParams)

        when (responseCode) {
            OK -> purchaseHistoryListener.result = result
            else -> responseHandler(responseCode, result)
        }
    }

    private fun getPurchaseHistory(result: Result, skuType: String) {
        billingClient.queryPurchaseHistoryAsync(skuType) { responseCode, data ->
            when (responseCode) {
                OK -> result.success(data?.map(::purchaseToMap))
                else -> responseHandler(responseCode, result)
            }
        }
    }

    private fun getProducts(result: Result, skus: List<String>, skuType: String) {
        val params = SkuDetailsParams.newBuilder()
                .setSkusList(skus)
                .setType(skuType)
                .build()

        billingClient.querySkuDetailsAsync(params) { responseCode, skuDetailsList ->
            when (responseCode) {
                OK -> result.success(skuDetailsList?.map(::productToMap))
                else -> responseHandler(responseCode, result)
            }
        }
    }
}

