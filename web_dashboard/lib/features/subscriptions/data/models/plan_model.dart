import 'package:equatable/equatable.dart';

class PlanModel extends Equatable {
  final int id;
  final String name;
  final double price;
  final int durationMonths;
  final List<String> features;
  final bool isActive;

  const PlanModel({
    required this.id,
    required this.name,
    required this.price,
    required this.durationMonths,
    required this.features,
    required this.isActive,
  });

  String get durationLabel => '$durationMonths شهر';
  String get priceLabel => '${price.toStringAsFixed(2)} ر.س';

  PlanModel copyWith({
    int? id,
    String? name,
    double? price,
    int? durationMonths,
    List<String>? features,
    bool? isActive,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      durationMonths: durationMonths ?? this.durationMonths,
      features: features ?? this.features,
      isActive: isActive ?? this.isActive,
    );
  }

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as int,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      durationMonths: json['duration_months'] as int,
      features: List<String>.from(json['features'] as List),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'duration_months': durationMonths,
      'features': features,
      'is_active': isActive,
    };
  }

  static List<PlanModel> dummyList = [
    const PlanModel(
      id: 1,
      name: 'الباقة الأساسية',
      price: 99.99,
      durationMonths: 6,
      features: [
        'الوصول للدروس الأساسية',
        'اختبارات تقييمية',
        'دعم فني عبر البريد',
      ],
      isActive: true,
    ),
    const PlanModel(
      id: 2,
      name: 'الباقة الفضية',
      price: 299.99,
      durationMonths: 6,
      features: [
        'الوصول لجميع الدروس',
        'اختبارات تقييمية متقدمة',
        'دعم فني عبر الدردشة',
        'تقارير أداء شهرية',
        'محتوى إضافي حصري',
      ],
      isActive: true,
    ),
    const PlanModel(
      id: 3,
      name: 'الباقة الذهبية',
      price: 499.99,
      durationMonths: 12,
      features: [
        'الوصول الكامل لجميع المحتوى',
        'اختبارات تقييمية غير محدودة',
        'دعم فني على مدار الساعة',
        'تقارير أداء أسبوعية',
        'محتوى إضافي حصري',
        'جلسات مراجعة مع المعلم',
        'شهادة إتمام',
      ],
      isActive: true,
    ),
    const PlanModel(
      id: 4,
      name: 'باقة تجريبية',
      price: 0.00,
      durationMonths: 1,
      features: [
        'الوصول للدروس الأساسية',
        'اختبار تقييمي واحد',
      ],
      isActive: true,
    ),
  ];

  @override
  List<Object?> get props => [id, name, price, durationMonths, features, isActive];
}
