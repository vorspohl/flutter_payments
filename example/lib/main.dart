import 'package:flutter/material.dart';
import 'package:flutter_payments/flutter_payments.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  List<String> logMessages = <String>[];

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: new Text('Flutter Payments'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: new Column(
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Text('Products for Purchase'),
              buildPurchaseButton(context, 'android.test.canceled'),
              buildPurchaseButton(context, 'android.test.purchased'),
              buildPurchaseButton(context, 'android.test.item_unavailable'),
              Text('Log Messages'),
              Text(logMessages.join('\n')),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildPurchaseButton(BuildContext context, String productSku) {
    return new RaisedButton(
      onPressed: () async {
        String message;
        try {
          final List<Purchase> list = await FlutterPayments.purchase(
            sku: productSku,
            type: ProductType.InApp,
          );

          message = list.toString();
        } on FlutterPaymentsException catch (error) {
          message = error.toString();
        }

        setState(() {
          logMessages.add('Purchase of "$productSku" result:\n$message');
        });
      },
      child: Text('Purchase "$productSku"'),
    );
  }
}
