# flutter_payments

Flutter In App Purchases For Humans.

[![pub package](https://img.shields.io/pub/v/flutter_payments.svg)](https://pub.dartlang.org/packages/flutter_payments)


## Getting Started

This plugin makes it easy to make products or subscriptions for both Apple App Store and Google Play.

### Subscriptions
You can use the built-in `SubscriptionManager` which provides a Stream interface for purchase states and abstracts away most of the logic around subscription management.  However, it does not perform extended validation of a Subscription, so it may be possible to inject an invalid Subscription depending on the platform and device security settings.  **It is recommended that you perform server-side validation of all purchases, *if that is a concern*.**

[SubscriptionManager Example](/example/lib/subscription_page.dart)

### In App Purchases (Non-subscription Products)
You can run the included example app on an Android device to test the payment flow with test product SKUs.

[Example App](./example/lib/main.dart)

##### FlutterPayments.billingEnabled
Determine if Billing is available on the device.
```dart
final bool billingEnabled = await FlutterPayments.billingEnabled;
```

#### FlutterPayments.getProducts
Fetch Product metadata from the store.

```dart
final List<Product> getProducts = await FlutterPayments.getProducts(
  skus: <String>[
    'android.test.purchased',
    'android.test.canceled',
  ],
  type: ProductType.InApp,
);
```

#### FlutterPayments.purchase
```dart
List<Purchase> purchase = await FlutterPayments.purchase(
  sku: 'android.test.purchased',
  type: ProductType.InApp,
);
```

#### FlutterPayments.getPurchaseHistory
Get the User's purchase history from the Store.  Returns a list of Purchase instances.
```dart
final List<Purchase> purchaseHistory = await FlutterPayments.getPurchaseHistory(ProductType.InApp);
print('purchaseHistory: $purchaseHistory');
```
