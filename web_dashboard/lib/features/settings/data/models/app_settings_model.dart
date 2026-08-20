import 'package:equatable/equatable.dart';

class AppSettingsModel extends Equatable {
  final String appName;
  final String? logoUrl;
  final String contactEmail;
  final String contactPhone;
  final Map<String, String> socialLinks;
  final bool enablePayment;
  final String defaultLanguage;
  final String baseUrl;
  final String apiKey;

  const AppSettingsModel({
    required this.appName,
    this.logoUrl,
    required this.contactEmail,
    required this.contactPhone,
    required this.socialLinks,
    required this.enablePayment,
    required this.defaultLanguage,
    required this.baseUrl,
    required this.apiKey,
  });

  AppSettingsModel copyWith({
    String? appName,
    String? logoUrl,
    String? contactEmail,
    String? contactPhone,
    Map<String, String>? socialLinks,
    bool? enablePayment,
    String? defaultLanguage,
    String? baseUrl,
    String? apiKey,
  }) {
    return AppSettingsModel(
      appName: appName ?? this.appName,
      logoUrl: logoUrl ?? this.logoUrl,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      socialLinks: socialLinks ?? this.socialLinks,
      enablePayment: enablePayment ?? this.enablePayment,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    final dynamic rawPayment = json['enablePayment'] ??
        json['enable_payment'] ??
        json['maintenanceMode'] ??
        json['maintenance_mode'];

    final bool parsedPayment = rawPayment == null
        ? true
        : (rawPayment == true ||
            rawPayment == 'true' ||
            rawPayment == 1 ||
            rawPayment == '1');

    return AppSettingsModel(
      appName: json['appName']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      contactEmail: json['contactEmail']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      socialLinks: json['socialLinks'] != null
          ? Map<String, String>.from(json['socialLinks'] as Map)
          : {},
      enablePayment: parsedPayment,
      defaultLanguage: json['defaultLanguage']?.toString() ?? 'ar',
      baseUrl: json['baseUrl']?.toString() ?? '',
      apiKey: json['apiKey']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'appName': appName,
      'logoUrl': logoUrl,
      'contactEmail': contactEmail,
      'contactPhone': contactPhone,
      'socialLinks': socialLinks,
      'enablePayment': enablePayment,
      'enable_payment': enablePayment,
      'maintenanceMode': enablePayment,
      'maintenance_mode': enablePayment,
      'defaultLanguage': defaultLanguage,
      'baseUrl': baseUrl,
      'apiKey': apiKey,
    };
  }

  static AppSettingsModel dummy = const AppSettingsModel(
    appName: 'قبة التعليمية',
    logoUrl: null,
    contactEmail: 'support@qubah.app',
    contactPhone: '+966501234567',
    socialLinks: {
      'facebook': 'https://facebook.com/qubahapp',
      'twitter': 'https://twitter.com/qubahapp',
      'instagram': 'https://instagram.com/qubahapp',
      'youtube': 'https://youtube.com/@qubahapp',
    },
    enablePayment: true,
    defaultLanguage: 'ar',
    baseUrl: 'https://qubahom.com/api/v1',
    apiKey: 'qubah-api-key-2026-xxxx-yyyy',
  );

  @override
  List<Object?> get props => [
        appName,
        logoUrl,
        contactEmail,
        contactPhone,
        socialLinks,
        enablePayment,
        defaultLanguage,
        baseUrl,
        apiKey,
      ];
}
