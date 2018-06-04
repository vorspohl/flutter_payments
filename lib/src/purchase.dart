import 'dateutils.dart';
import 'product.dart';

class Purchase {
  final String orderId;
  final String packageName;
  final String purchaseToken;
  final DateTime purchaseTime;
  final bool autoRenewing;
  final String sku;
  final String signature;

  Product product;

  Purchase({
    this.orderId,
    this.packageName,
    this.purchaseToken,
    this.purchaseTime,
    this.autoRenewing,
    this.sku,
    this.signature,
  });

  bool get isActive {
    return purchaseExpires is DateTime && purchaseExpires.isAfter(DateTime.now());
  }

  bool get isTrialPeriod {
    assert(product is SubscriptionProduct);
    var sub = product as SubscriptionProduct;

    return sub.freeTrialPeriod.valid && _addPeriodToPurchaseTime(sub.freeTrialPeriod).isAfter(DateTime.now());
  }

  DateTime get purchaseExpires {
    assert(product is SubscriptionProduct);
    var sub = product as SubscriptionProduct;

    if (sub.subscriptionPeriod.valid) {
      return _addPeriodToPurchaseTime(sub.subscriptionPeriod);
    }

    return null;
  }

  DateTime _addPeriodToPurchaseTime(Period period) {
    int length = period.length;

    switch (period.type) {
      case 'month':
        return addMonths(purchaseTime, length);
      case 'week':
        return addWeeks(purchaseTime, length);
    }

    return purchaseTime.add(Duration(days: length));
  }

  static Purchase fromMap(dynamic data) {
    print('Purchase.fromMap: $data');

    if (data is Map) {
      data = data as Map<dynamic, dynamic>;
      return Purchase(
        orderId: data['orderId'],
        packageName: data['packageName'],
        purchaseToken: data['purchaseToken'],
        autoRenewing: data['isAutoRenewing'] as bool,
        purchaseTime: DateTime.fromMillisecondsSinceEpoch(data['purchaseTime']),
        sku: data['sku'],
        signature: data['signature'],
      );
    }

    throw new Exception("Got bad data: $data");
  }
}
