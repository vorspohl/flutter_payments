package co.delightfulgoods.flutterpayments

import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClient.BillingResponse.*
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.SkuDetails
import io.flutter.plugin.common.MethodChannel

internal class PurchaseHistoryListener : PurchasesUpdatedListener {
    var result: MethodChannel.Result? = null

    override fun onPurchasesUpdated(responseCode: Int, purchases: MutableList<Purchase>?) {
        if (result == null) {
            return
        }

        when (responseCode) {
            OK -> result!!.success(purchases?.map(::purchaseToMap))
            else -> responseHandler(responseCode, result!!)
        }

        result = null
    }
}

internal fun responseHandler(responseCode: Int, result: MethodChannel.Result) {
    when (responseCode) {
        USER_CANCELED -> result.error("USER_CANCELED", null, null)
        ITEM_UNAVAILABLE -> result.error("ITEM_UNAVAILABLE", null, null)
        ITEM_ALREADY_OWNED -> result.error("ITEM_ALREADY_OWNED", null, null)
        ITEM_NOT_OWNED -> result.error("ITEM_NOT_OWNED", null, null)
        SERVICE_UNAVAILABLE, BILLING_UNAVAILABLE -> result.error("BILLING_UNAVAILABLE", null, null)
        else -> result.error("ERROR", null, null)
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

internal fun productToMap(skuDetail: SkuDetails): Map<String, String> {
    return mapOf(
            "sku" to skuDetail.sku,
            "title" to skuDetail.title,
            "description" to skuDetail.description,
            "price" to skuDetail.price,
            "freeTrialPeriod" to skuDetail.freeTrialPeriod,
            "introductoryPrice" to skuDetail.introductoryPrice,
            "introductoryPricePeriod" to skuDetail.introductoryPricePeriod,
            "introductoryPriceCycles" to skuDetail.introductoryPriceCycles,
            "subscriptionPeriod" to skuDetail.subscriptionPeriod
    )
}


internal fun strToSkuType(typeStr: String): String {
    return when (typeStr) {
        "ProductType.InApp" -> BillingClient.SkuType.INAPP
        "ProductType.Subscription" -> BillingClient.SkuType.SUBS
        else -> throw Exception("Unknown typeStr: $typeStr")
    }
}
