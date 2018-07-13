import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_payments/flutter_payments.dart';

class ManageSubscriptionPage extends StatefulWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  ManageSubscriptionPageState createState() => new ManageSubscriptionPageState();
}

class ManageSubscriptionPageState extends State<ManageSubscriptionPage> {
  StreamSubscription<Purchase> _purchaseStream;

  @override
  void initState() {
    super.initState();

    _purchaseStream = SubscriptionManager.instance.stream.listen((Purchase e) => setState(() {}));
    SubscriptionManager.instance.refresh(['my_subscription_sku']);
  }

  @override
  void dispose() {
    _purchaseStream?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> list = <Widget>[];

    final Purchase activePurchase = SubscriptionManager.instance.activePurchase;
    if (activePurchase != null) {
      list.add(Text('Subscribed to: ${activePurchase.product.title}'));
    } else {
      final List<Widget> result = SubscriptionManager.instance.products?.map(buildPurchaseButton)?.toList();
      if (result != null) {
        list.addAll(result);
      }
    }

    return ListView(
      controller: widget._scrollController,
      children: list,
    );
  }

  Widget buildPurchaseButton(SubscriptionProduct p) => RaisedButton(
        child: Text('Purchase ${p.title}'),
        onPressed: () {
          SubscriptionManager.instance.initiatePurchase(p);
        },
      );
}
