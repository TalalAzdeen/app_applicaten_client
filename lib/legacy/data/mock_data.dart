import '../models/models.dart';

class AppRepository {
  static final List<ServiceCategory> categories = [
    const ServiceCategory(id: 'c1', name: 'سباكة', iconName: 'plumbing'),
    const ServiceCategory(id: 'c2', name: 'كهرباء', iconName: 'electric_bolt'),
    const ServiceCategory(id: 'c3', name: 'تكييف وتبريد', iconName: 'ac_unit'),
    const ServiceCategory(id: 'c4', name: 'نظافة وتطهير', iconName: 'cleaning_services'),
    const ServiceCategory(id: 'c5', name: 'دهانات وديكور', iconName: 'format_paint'),
    const ServiceCategory(id: 'c6', name: 'أجهزة منزلية', iconName: 'kitchen'),
  ];

  static final List<ServiceItem> services = [
    const ServiceItem(
      id: 's1',
      categoryId: 'c1',
      name: 'تسريب مياه إصلاح عام',
      description: 'فحص وإصلاح تسريبات الأنابيب والحنفيات والوصلات الرئيسية.',
      pricingType: PricingType.range,
      minPrice: 80,
      maxPrice: 250,
    ),
    const ServiceItem(
      id: 's2',
      categoryId: 'c1',
      name: 'تركيب أدوات صحية',
      description: 'تركيب خلاطات، مغاسل، أو كراسي حمام مع التثبيت والضمان.',
      pricingType: PricingType.fixed,
      fixedPrice: 150,
    ),
    const ServiceItem(
      id: 's3',
      categoryId: 'c3',
      name: 'صيانة وتعبئة فريون مكيف سبليت',
      description: 'غسيل الوحدة الخارجية والداخلية وتعبئة غاز الفريون الأصلي.',
      pricingType: PricingType.fixed,
      fixedPrice: 180,
    ),
    const ServiceItem(
      id: 's4',
      categoryId: 'c2',
      name: 'تأسيس وإصلاح أعطال الكهرباء',
      description: 'معاينة القواطع والأفياش وإصلاح الشورت الكهربائي.',
      pricingType: PricingType.requiredQuote,
    ),
  ];

  static final List<CustomerAddress> addresses = [
    const CustomerAddress(
      id: 'a1',
      label: 'المنزل - الرياض',
      fullAddress: 'حي الملقا، طريق أنس بن مالك، مبنى 14',
      latitude: 24.7136,
      longitude: 46.6753,
      isDefault: true,
    ),
    const CustomerAddress(
      id: 'a2',
      label: 'المكتب',
      fullAddress: 'حي العليا، طريق الملك فهد، برج 3',
      latitude: 24.6900,
      longitude: 46.6850,
    ),
  ];

  static List<OrderModel> sampleOrders = [
    OrderModel(
      id: 'o1',
      referenceNumber: 'SAL-9041',
      service: services[2], // تكييف
      address: addresses[0],
      description: 'المكيف يخرج هواء حار مع صوت مرتفع من الوحدة الخارجية',
      status: OrderStatus.enRoute,
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      organizationName: 'مؤسسة التبريد المتقدم للصيانة',
      technicianName: 'أحمد محمود',
      technicianPhone: '0501234567',
      currentQuote: QuoteModel(
        id: 'q1',
        orderId: 'o1',
        organizationName: 'مؤسسة التبريد المتقدم للصيانة',
        laborFee: 150.0,
        sparePartsFee: 50.0,
        taxAmount: 30.0,
        totalAmount: 230.0,
        isAccepted: true,
        createdAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
      hasWarranty: true,
    ),
    OrderModel(
      id: 'o2',
      referenceNumber: 'SAL-8812',
      service: services[0], // سباكة
      address: addresses[0],
      description: 'انسداد في مجرى المطبخ الرئيسي',
      status: OrderStatus.searching,
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
    OrderModel(
      id: 'o3',
      referenceNumber: 'SAL-7732',
      service: services[1], // تركيب أدوات صحية
      address: addresses[1],
      description: 'تركيب 2 خلاط مغسلة جديد',
      status: OrderStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      organizationName: 'مؤسسة السباكة الحديثة',
      technicianName: 'خالد السعيد',
      isPaid: true,
      finalPrice: 150.0,
      rating: 5.0,
      reviewComment: 'خدمة ممتازة وسريعة جداً وشغل نظيف',
      hasWarranty: true,
    ),
  ];

  static double walletBalance = 120.0;
  static double cashbackEarned = 35.0;
}
