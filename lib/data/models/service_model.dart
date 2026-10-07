enum PricingType { fixed, range, requiredQuote }

class ServiceCategory {
  final String id;
  final String name;
  final String iconName;

  const ServiceCategory({
    required this.id,
    required this.name,
    required this.iconName,
  });
}

class ServiceItem {
  final String id;
  final String categoryId;
  final String name;
  final String description;
  final PricingType pricingType;
  final double? fixedPrice;
  final double? minPrice;
  final double? maxPrice;

  const ServiceItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.description,
    required this.pricingType,
    this.fixedPrice,
    this.minPrice,
    this.maxPrice,
  });

  String get formattedPrice {
    switch (pricingType) {
      case PricingType.fixed:
        return '${fixedPrice?.toStringAsFixed(0)} ر.س';
      case PricingType.range:
        return '${minPrice?.toStringAsFixed(0)} - ${maxPrice?.toStringAsFixed(0)} ر.س';
      case PricingType.requiredQuote:
        return 'حسب معاينة الفني (عرض سعر)';
    }
  }
}

class CustomerAddress {
  final String id;
  final String label;
  final String fullAddress;
  final double latitude;
  final double longitude;
  final bool isDefault;
  final double? accuracyMeters;

  const CustomerAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
    this.accuracyMeters,
  });
}
