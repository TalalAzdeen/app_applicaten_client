enum PricingType { fixed, range, requiredQuote }

enum OrderStatus {
  submitted, // مُرسل
  searching, // جارٍ البحث عن منفذ
  assigned, // تم التعاقد / تعيين الفني
  enRoute, // الفني في الطريق (Live Tracking active)
  arrived, // وصل الفني
  inProgress, // قيد التنفيذ
  completed, // مكتمل
  cancelled // ملغي
}

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
  final String label; // المنزل، العمل...
  final String fullAddress;
  final double latitude;
  final double longitude;
  final bool isDefault;

  const CustomerAddress({
    required this.id,
    required this.label,
    required this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.isDefault = false,
  });
}

class QuoteModel {
  final String id;
  final String orderId;
  final String organizationName;
  final double laborFee;
  final double sparePartsFee;
  final double taxAmount; // VAT 15%
  final double totalAmount;
  final bool isAccepted;
  final bool isExpired;
  final DateTime createdAt;

  const QuoteModel({
    required this.id,
    required this.orderId,
    required this.organizationName,
    required this.laborFee,
    required this.sparePartsFee,
    required this.taxAmount,
    required this.totalAmount,
    this.isAccepted = false,
    this.isExpired = false,
    required this.createdAt,
  });
}

class OrderModel {
  final String id;
  final String referenceNumber; // e.g. SAL-8921
  final ServiceItem service;
  final CustomerAddress address;
  final String description;
  final OrderStatus status;
  final DateTime createdAt;
  final DateTime? scheduledFor;
  final String? organizationName;
  final String? technicianName;
  final String? technicianPhone;
  final QuoteModel? currentQuote;
  final bool isPaid;
  final double? finalPrice;
  final double? rating;
  final String? reviewComment;
  final bool hasWarranty;

  const OrderModel({
    required this.id,
    required this.referenceNumber,
    required this.service,
    required this.address,
    required this.description,
    required this.status,
    required this.createdAt,
    this.scheduledFor,
    this.organizationName,
    this.technicianName,
    this.technicianPhone,
    this.currentQuote,
    this.isPaid = false,
    this.finalPrice,
    this.rating,
    this.reviewComment,
    this.hasWarranty = false,
  });

  bool get canTrackTechnician => status == OrderStatus.enRoute || status == OrderStatus.arrived;
  bool get canChat => status != OrderStatus.submitted && status != OrderStatus.cancelled;
}

class ChatMessage {
  final String id;
  final String senderName;
  final String message;
  final DateTime timestamp;
  final bool isFromCustomer;

  const ChatMessage({
    required this.id,
    required this.senderName,
    required this.message,
    required this.timestamp,
    required this.isFromCustomer,
  });
}
