import 'service_model.dart';

enum OrderStatus {
  submitted, // مُرسل
  searching, // جارٍ البحث عن منصة/فني
  assigned, // تم التعاقد / تعيين الفني
  enRoute, // الفني في الطريق (تتبع حي)
  arrived, // وصل الفني
  inProgress, // قيد التنفيذ
  completed, // مكتمل
  cancelled // ملغي
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
  final String referenceNumber;
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

  OrderModel copyWith({bool? isPaid}) => OrderModel(
    id: id, referenceNumber: referenceNumber, service: service, address: address,
    description: description, status: status, createdAt: createdAt,
    scheduledFor: scheduledFor, organizationName: organizationName,
    technicianName: technicianName, technicianPhone: technicianPhone,
    currentQuote: currentQuote, isPaid: isPaid ?? this.isPaid, finalPrice: finalPrice,
    rating: rating, reviewComment: reviewComment, hasWarranty: hasWarranty,
  );

  bool get canTrackTechnician => status == OrderStatus.enRoute || status == OrderStatus.arrived;
  bool get canChat => status != OrderStatus.submitted && status != OrderStatus.cancelled;
}
