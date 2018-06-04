import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'product.dart';
import 'purchase.dart';
import 'types.dart';

class FlutterPayments {
  static const MethodChannel _channel = const MethodChannel('co.delightfulgoods.flutterpayments');

  static Future<List<Purchase>> getPurchaseHistory(ProductType type) async {
    try {
      return await inflatePurchases(
        await _channel.invokeMethod(
          'getPurchaseHistory',
          {
            "productType": type.toString(),
          },
        ),
        type,
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case "ITEM_UNAVAILABLE":
          throw ItemUnavailable();
        case "ITEM_ALREADY_OWNED":
          throw ItemAlreadyOwned();
      }
    }

    return null;
  }

  static Future<List<Purchase>> inflatePurchases(List result, ProductType type) async {
    if (result == null) {
      return null;
    }

    var purchases = result.map<Purchase>(Purchase.fromMap).toList(growable: false);

    List<Product> products = await getProducts(
      skus: purchases.map((Purchase p) => p.sku).toList(),
      type: type,
    );

    if (products != null) {
      Map<String, Product> index = {};
      for (var p in products) {
        index[p.sku] = p;
      }

      for (var p in purchases) {
        if (index.containsKey(p.sku)) {
          p.product = index[p.sku];
        }
      }
    }

    return purchases;
  }

  static Future<List<Product>> getProducts({List<String> skus, ProductType type}) async {
    var result = await _channel.invokeMethod(
      'getProducts',
      {
        "skus": skus,
        "productType": type.toString(),
      },
    );

    if (result == null) {
      return null;
    }

    if (type == ProductType.InApp) {
      return result.map<Product>(Product.fromMap).toList(growable: false);
    }

    return result.map<SubscriptionProduct>(SubscriptionProduct.fromMap).toList(growable: false);
  }

  static Future<bool> get billingEnabled async => await _channel.invokeMethod('billingEnabled');

  static Future<List<Purchase>> purchase({String sku, ProductType type}) async {
    try {
      return inflatePurchases(
        await _channel.invokeMethod(
          'purchase',
          {
            "sku": sku,
            "productType": type.toString(),
          },
        ),
        type,
      );
    } on PlatformException catch (e) {
      switch (e.code) {
        case "ITEM_UNAVAILABLE":
          throw ItemUnavailable();
        case "ITEM_ALREADY_OWNED":
          throw ItemAlreadyOwned();
      }
    }

    return null;
  }

  static modifySubscription({
    String newSku,
    String oldSku,
  }) async =>
      await _channel.invokeMethod(
        'modifySubscription',
        {
          "oldSku": oldSku,
          "newSku": newSku,
        },
      );

  static launchManageSubscription() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      const url = 'https://play.google.com/store/account/subscriptions';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }
}
