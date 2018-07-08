import 'package:flutter/material.dart';
import 'package:flutter_payments/flutter_payments.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  void initPlatformState() async {
    final bool billingEnabled = await FlutterPayments.billingEnabled;
    print('billingEnabled: $billingEnabled');

    final List<Product> getProducts = await FlutterPayments.getProducts(
      skus: <String>[
        'android.test.purchased',
        'android.test.canceled',
      ],
      type: ProductType.InApp,
    );
    print('getProducts: $getProducts');

    List<Purchase> purchase = await FlutterPayments.purchase(
      sku: 'android.test.purchased',
      type: ProductType.InApp,
    );
    print('purchase: $purchase');

    purchase = await FlutterPayments.purchase(
      sku: 'android.test.canceled',
      type: ProductType.InApp,
    );
    print('purchase: $purchase');

    purchase = await FlutterPayments.purchase(
      sku: 'android.test.unavailable',
      type: ProductType.InApp,
    );
    print('purchase: $purchase');

    purchase = await FlutterPayments.modifySubscription(
      newSku: 'android.test.purchased',
      oldSku: 'android.test.unavailable',
    );
    print('purchase: $purchase');

    final List<Purchase> purchaseHistory = await FlutterPayments.getPurchaseHistory(ProductType.InApp);
    print('purchaseHistory: $purchaseHistory');
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Check the Flutter logs.'),
        ),
      ),
    );
  }
}
