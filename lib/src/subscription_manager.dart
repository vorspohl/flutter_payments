import 'dart:async';

import 'package:flutter_payments/flutter_payments.dart';

class SubscriptionManager {
  StreamController<Purchase> _streamController;
  Purchase _activePurchase;
  List<SubscriptionProduct> _products;

  SubscriptionManager() {
    _streamController = StreamController<Purchase>.broadcast(onListen: () {
      _streamController.add(activePurchase);
    });
  }

  static SubscriptionManager _instance;

  static SubscriptionManager get instance => _instance ??= SubscriptionManager();

  Stream<Purchase> get stream => _streamController.stream;

  Purchase get activePurchase => _activePurchase;

  List<SubscriptionProduct> get products => _products;

  bool get hasValidSubscription {
    if (_activePurchase != null) {
      return _activePurchase.isActive;
    }

    return false;
  }

  Future<List<Object>> refresh(List<String> skusToRefresh) {
    return Future.wait(<Future<Object>>[
      FlutterPayments
          .getProducts(
        skus: skusToRefresh,
        type: ProductType.Subscription,
      )
          .then((List<Product> result) {
        if (result.isNotEmpty) {
          _products = result.cast<SubscriptionProduct>();
        }
      }),
      FlutterPayments.getPurchases(ProductType.Subscription).then(updatePurchases)
    ]);
  }

  List<Purchase> updatePurchases(List<Purchase> purchases) {
    _activePurchase = null;

    if (purchases != null) {
      for (Purchase p in purchases) {
        if (p.isActive) {
          _activePurchase = p;
          _streamController.add(p);
          break;
        }
      }
    }

    if (_activePurchase == null) {
      _streamController.add(null);
    }

    return <Purchase>[_activePurchase];
  }

  Future<Null> initiatePurchase(Product product) async => updatePurchases(await FlutterPayments.purchase(
        sku: product.sku,
        type: ProductType.Subscription,
      ));
}
