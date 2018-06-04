import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_payments/flutter_payments.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';

  @override
  initState() {
    super.initState();
    initPlatformState();
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  initPlatformState() async {
    String platformVersion;
    var billingEnabled = await FlutterPayments.billingEnabled;
    print('billingEnabled: $billingEnabled');

    var getProducts = await FlutterPayments.getProducts(
      skus: [
        "android.test.purchased",
        "android.test.canceled",
      ],
      type: ProductType.InApp,
    );
    print('getProducts: $getProducts');

    var purchase = await FlutterPayments.purchase(
      sku: "android.test.purchased",
      type: ProductType.InApp,
    );
    print('purchase: $purchase');

    purchase = await FlutterPayments.purchase(
      sku: "android.test.canceled",
      type: ProductType.InApp,
    );
    print('purchase: $purchase');

    purchase = await FlutterPayments.purchase(
      sku: "android.test.unavailable",
      type: ProductType.InApp,
    );
    print('purchase: $purchase');

    purchase = await FlutterPayments.modifySubscription(
      newSku: "android.test.purchased",
      oldSku: "android.test.unavailable",
    );
    print('purchase: $purchase');

    var purchaseHistory =
        await FlutterPayments.getPurchaseHistory(ProductType.InApp);
    print('purchaseHistory: $purchaseHistory');

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });

    var exitDuration = const Duration(seconds: 60);
    Future<void>.delayed(exitDuration, () {
      print('Automatically exited after $exitDuration');
      exit(1);
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Plugin example app'),
        ),
        body: new Center(
          child: new Text('Running on: $_platformVersion\n'),
        ),
      ),
    );
  }
}
