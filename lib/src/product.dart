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

    throw new Exception('Got bad data: $data');
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
        freeTrialPeriod: Period.ifValid(data['freeTrialPeriod']),
        introductoryPrice: data['introductoryPrice'],
        introductoryPricePeriod: Period.ifValid(data['introductoryPricePeriod']),
        introductoryPriceCycles: data['introductoryPriceCycles'],
        subscriptionPeriod: Period.ifValid(data['subscriptionPeriod']),
      );
    }

    throw new Exception('Got bad data: $data');
  }

  List<String> get planDescription {
    final List<String> parts = <String>[];

    if (freeTrialPeriod != null) {
      parts.add('Includes a free trial for ${freeTrialPeriod.toString()}');
    }

    if (introductoryPricePeriod != null) {
      final String introPeriod = introductoryPricePeriod.toString();
      parts.add(('Introductory price of **$introductoryPrice**/$introPeriod for **$introductoryPriceCycles** cycles.'));
    }

    final String period = subscriptionPeriod.toString();
    parts.add('Subscription is **$price**/$period');

    return parts;
  }
}

class Period {
  final String _input;

  Period._internal(this._input);

  factory Period.ifValid(String input) {
    if (input is String && input.length >= 3) {
      return Period._internal(input);
    }

    return null;
  }

  String get type {
    switch (_input[_input.length - 1]) {
      case 'D':
        return 'day';
      case 'W':
        return 'week';
      case 'M':
        return 'month';
      case 'Y':
        return 'year';
      default:
        return 'unknown';
    }
  }

  int get length {
    return int.tryParse(_input.substring(1, _input.length - 1));
  }

  @override
  String toString() {
    if (length == 1) {
      return type;
    } else {
      return '$length ${type}s';
    }
  }
}
