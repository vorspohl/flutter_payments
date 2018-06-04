package co.delightfulgoods.flutterpayments

import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClient.BillingResponse.ERROR
import com.android.billingclient.api.BillingClient.BillingResponse.OK
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import io.flutter.plugin.common.MethodChannel

internal class PurchaseHistoryListener : PurchasesUpdatedListener {
    var result: MethodChannel.Result? = null

    override fun onPurchasesUpdated(responseCode: Int, purchases: MutableList<Purchase>?) {
        if (result == null) {
            return;
        }

        when (responseCode) {
            OK -> {
                if (purchases == null) {
                    result!!.success(null);
                } else {
                    result!!.success(purchases.map(::purchaseToMap))
                }
            }

            ERROR -> result!!.error("ERROR", "An error occurred when requesting to purchase. BillingResult = $responseCode", null);
            else -> result!!.error("ERROR", "An unknown error occurred when requesting to purchase. BillingResult = $responseCode", null);
        }

        result = null;
    }
}

internal fun purchaseToMap(purchaseDetail: Purchase): Map<String, Any> = mapOf(
        "orderId" to purchaseDetail.orderId,
        "packageName" to purchaseDetail.packageName,
        "purchaseToken" to purchaseDetail.purchaseToken,
        "isAutoRenewing" to purchaseDetail.isAutoRenewing,
        "purchaseTime" to purchaseDetail.purchaseTime,
        "sku" to purchaseDetail.sku,
        "signature" to purchaseDetail.signature
)

internal fun strToSkuType(typeStr: String): String {
    return when (typeStr) {
        "ProductType.InApp" -> BillingClient.SkuType.INAPP
        "ProductType.Subscription" -> BillingClient.SkuType.SUBS
        else -> throw Exception("Unknown typeStr: $typeStr")
    }
}
