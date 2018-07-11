import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

import 'product.dart';
import 'purchase.dart';
import 'types.dart';

class FlutterPayments {
  static const MethodChannel _channel = const MethodChannel('co.delightfulgoods.flutterpayments');

  static Future<List<Purchase>> getPurchaseHistory(ProductType type) async => await _inflatePurchases(
        await _channel.invokeMethod(
          'getPurchaseHistory',
          <String, dynamic>{
            'productType': type.toString(),
          },
        ),
        type,
      );

  static Future<List<Purchase>> getPurchases(ProductType type) async => await _inflatePurchases(
        await _channel.invokeMethod(
          'getPurchaseHistory',
          <String, dynamic>{
            'productType': type.toString(),
          },
        ),
        type,
      );

  static Future<List<Product>> getProducts({List<String> skus, ProductType type}) async {
    final List<dynamic> result = await _channel.invokeMethod(
      'getProducts',
      <String, dynamic>{
        'skus': skus,
        'productType': type.toString(),
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
      return _inflatePurchases(
        await _channel.invokeMethod(
          'purchase',
          <String, dynamic>{
            'sku': sku,
            'productType': type.toString(),
          },
        ),
        type,
      );
    } on PlatformException catch (e) {
      throw FlutterPaymentsException.fromPlatformException(e);
    }
  }

  static Future<String> consumeToken(String token) async {
    return await _channel.invokeMethod(
      'consumeToken',
      <String, dynamic>{
        'token': token,
      },
    );
  }

  static Future<List<Purchase>> modifySubscription({
    String newSku,
    String oldSku,
  }) async =>
      await _channel.invokeMethod(
        'modifySubscription',
        <String, dynamic>{
          'oldSku': oldSku,
          'newSku': newSku,
        },
      );

  static void launchManageSubscription() async {
    if (defaultTargetPlatform == TargetPlatform.android) {
      const String url = 'https://play.google.com/store/account/subscriptions';
      if (await canLaunch(url)) {
        await launch(url);
      }
    }
  }
}

Future<List<Purchase>> _inflatePurchases(List<dynamic> result, ProductType type) async {
  if (result == null || result.isEmpty) {
    return null;
  }

  final List<Purchase> purchases = result.map<Purchase>(Purchase.fromMap).toList(growable: false);

  final List<Product> products = await FlutterPayments.getProducts(
    skus: purchases.map((Purchase p) => p.sku).toList(),
    type: type,
  );

  if (products != null && products.isNotEmpty) {
    final Map<String, Product> index = <String, Product>{};
    for (Product p in products) {
      index[p.sku] = p;
    }

    for (Purchase p in purchases) {
      if (index.containsKey(p.sku)) {
        p.product = index[p.sku];
      }
    }
  }

  return purchases;
}
