class Product {
  final String sku;
  final String title;
  final String description;
  final String price;

  Product({this.sku, this.title, this.description, this.price});

  static Product fromMap(dynamic data) {
    print('Product.fromMap: $data');
    if (data is Map) {
      data = data as Map<dynamic, dynamic>;
      return Product(
        sku: data['sku'],
        title: data['title'],
        description: data['description'],
        price: data['price'],
      );
    }

    throw new Exception("Got bad data: $data");
  }
}

class SubscriptionProduct extends Product {
  final Period freeTrialPeriod;
  final String introductoryPrice;
  final Period introductoryPricePeriod;
  final String introductoryPriceCycles;
  final Period subscriptionPeriod;

  SubscriptionProduct({
    String sku,
    String title,
    String description,
    String price,
    this.freeTrialPeriod,
    this.introductoryPrice,
    this.introductoryPricePeriod,
    this.introductoryPriceCycles,
    this.subscriptionPeriod,
  }) : super(
          sku: sku,
          title: title,
          description: description,
          price: price,
        );

  static SubscriptionProduct fromMap(dynamic data) {
    print('SubscriptionProduct.fromMap: $data');
    if (data is Map) {
      data = data as Map<dynamic, dynamic>;
      return SubscriptionProduct(
        sku: data['sku'],
        title: data['title'],
        description: data['description'],
        price: data['price'],
        freeTrialPeriod: Period(data['freeTrialPeriod']),
        introductoryPrice: data['introductoryPrice'],
        introductoryPricePeriod: Period(data['introductoryPricePeriod']),
        introductoryPriceCycles: data['introductoryPriceCycles'],
        subscriptionPeriod: Period(data['subscriptionPeriod']),
      );
    }

    throw new Exception("Got bad data: $data");
  }
}

class Period {
  final String _input;

  Period(this._input);

  bool get valid => _input is String && _input.length >= 3;

  String get type {
    if (!valid) return null;

    switch (_input[_input.length - 1]) {
      case 'D':
        return 'day';
      case 'W':
        return 'week';
      case 'M':
        return 'month';
      default:
        return 'unknown';
    }
  }

  int get length {
    if (!valid) return null;

    return int.tryParse(_input.substring(1, _input.length - 1));
  }

  @override
  String toString() {
    if (!valid) return null;

    if (length == 1) {
      return type;
    } else {
      return '$length ${type}s';
    }
  }
}
