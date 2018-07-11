import Flutter
import UIKit
import StoreKit

public class SwiftFlutterPaymentsPlugin: NSObject, FlutterPlugin {
    var cachedProducts: [String: SKProduct] = [:]
    var productRequest: ProductRequestHandler?
    var transactionHandler: PaymentTransactionHandler
    
    override init() {
        transactionHandler = PaymentTransactionHandler()
        SKPaymentQueue.default().add(transactionHandler)
        
        super.init()
    }
    
     static let instance:SwiftFlutterPaymentsPlugin = SwiftFlutterPaymentsPlugin()
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        let callArgs = call.arguments as? Dictionary<String, Any>

        switch call.method {
            case "getPurchaseHistory": getPurchaseHistory(result)
            case "getProducts": getProducts(result, callArgs!["skus"] as! [String])
            case "purchase": purchase(result, callArgs!["sku"] as! String)
            case "billingEnabled": result(billingEnabled)

            default: result(FlutterMethodNotImplemented)
        }
    }
    
    var billingEnabled: Bool {
        get { return SKPaymentQueue.canMakePayments(); }
    }
    
    public func purchase(_ result: FlutterResult, _ sku: String) {
        if let product = cachedProducts[sku] {
            let payment = SKPayment(product: product)
            SKPaymentQueue.default().add(payment)
        }
    }
    
    public func getPurchaseHistory(_ result: @escaping FlutterResult) {
        transactionHandler.flutterResult = result
        SKPaymentQueue.default().restoreCompletedTransactions()
    }
    
    public func getProducts(_ result: @escaping FlutterResult, _ skus: [String]) {
        let request = SKProductsRequest(productIdentifiers:  NSSet(array: skus) as! Set<String>)
        productRequest = ProductRequestHandler(result)
        request.delegate = productRequest
        request.start()
    }
}


class ProductRequestHandler : NSObject, SKProductsRequestDelegate {
    var flutterResult : FlutterResult?
    
    init(_ result: @escaping FlutterResult) {
        self.flutterResult = result;
    }
    
    func productsRequest(_ request: SKProductsRequest, didReceive response: SKProductsResponse) {
        flutterResult?(response.products.map(productToDictionary))
    }
    
    private func productToDictionary(_ productData:SKProduct) -> Dictionary<String, Any> {
        // SwiftFlutterPaymentsPlugin.instance.cachedProducts[productData.productIdentifier] = productData
        
        let numberFormatter = NumberFormatter()
        numberFormatter.formatterBehavior = .behavior10_4
        numberFormatter.numberStyle = .currency
        numberFormatter.locale = productData.priceLocale
    
        return [
            "sku": productData.productIdentifier,
            "title": productData.localizedTitle,
            "description": productData.localizedDescription,
            "price": numberFormatter.string(from: productData.price) ?? "",
        ]
    }
}


class PaymentTransactionHandler : NSObject, SKPaymentTransactionObserver {
    var flutterResult : FlutterResult?
    
    func paymentQueue(_ queue: SKPaymentQueue, updatedTransactions transactions: [SKPaymentTransaction]) {
        var payments:Array<Dictionary<String, Any>> = []
        
        for transaction in transactions {
            switch transaction.transactionState {
            case .failed:
                queue.finishTransaction(transaction)
                print("Transaction Failed \(transaction)")
            case .purchased, .restored:
                queue.finishTransaction(transaction)
                print("Transaction purchased or restored: \(transaction)")
                payments.append(paymentToDictionary(transaction))
            case .deferred, .purchasing:
                print("Transaction in progress: \(transaction)")
            }
        }
        
        if(payments.count > 0) {
            flutterResult!(payments)
            flutterResult = nil
        }
    }
    
    private func paymentToDictionary(_ paymentData:SKPaymentTransaction) -> Dictionary<String, Any> {
        var purchaseTime:Int?
        
        if(paymentData.transactionDate != nil) {
            purchaseTime  = Int((paymentData.transactionDate!.timeIntervalSince1970 * 1000.0).rounded())
        }
        
        return [
            "orderId": paymentData.transactionIdentifier!,
            "packageName": paymentData.payment.productIdentifier,
            "purchaseTime": purchaseTime!,
            "sku": paymentData.payment.productIdentifier,
        ]
    }
}
