import 'package:flutter/services.dart';

enum ProductType { InApp, Subscription }

abstract class FlutterPaymentsException implements Exception {
  final String message;

  const FlutterPaymentsException([this.message = '']);

  factory FlutterPaymentsException.fromPlatformException(PlatformException error) {
    final String message = error.message;

    switch (error.code) {
      case 'USER_CANCELED':
        throw UserCanceled(message);
      case 'ITEM_UNAVAILABLE':
        throw ItemUnavailable(message);
      case 'ITEM_ALREADY_OWNED':
        throw ItemAlreadyOwned(message);
      case 'BILLING_UNAVAILABLE':
        throw BillingUnavailable(message);
      default:
        throw PurchaseError(message);
    }
  }
}

class UserCanceled extends FlutterPaymentsException {
  UserCanceled(String message) : super(message);
}

class ItemUnavailable extends FlutterPaymentsException {
  ItemUnavailable(String message) : super(message);
}

class ItemAlreadyOwned extends FlutterPaymentsException {
  ItemAlreadyOwned(String message) : super(message);
}

class BillingUnavailable extends FlutterPaymentsException {
  BillingUnavailable(String message) : super(message);
}

class PurchaseError extends FlutterPaymentsException {
  PurchaseError(String message) : super(message);
}
