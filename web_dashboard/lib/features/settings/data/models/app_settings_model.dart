import 'package:equatable/equatable.dart';

class AppSettingsModel extends Equatable {
  final String appName;
  final String? logoUrl;
  final String contactEmail;
  final String contactPhone;
  final Map<String, String> socialLinks;
  final bool maintenanceMode;
  final String defaultLanguage;
  final String baseUrl;
  final String apiKey;

  const AppSettingsModel({
    required this.appName,
    this.logoUrl,
    required this.contactEmail,
    required this.contactPhone,
    required this.socialLinks,
    required this.maintenanceMode,
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
    bool? maintenanceMode,
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
      maintenanceMode: maintenanceMode ?? this.maintenanceMode,
      defaultLanguage: defaultLanguage ?? this.defaultLanguage,
      baseUrl: baseUrl ?? this.baseUrl,
      apiKey: apiKey ?? this.apiKey,
    );
  }

  factory AppSettingsModel.fromJson(Map<String, dynamic> json) {
    return AppSettingsModel(
      appName: json['app_name'] as String? ?? '',
      logoUrl: json['logo_url'] as String?,
      contactEmail: json['contact_email'] as String? ?? '',
      contactPhone: json['contact_phone'] as String? ?? '',
      socialLinks: json['social_links'] != null
          ? Map<String, String>.from(json['social_links'] as Map)
          : {},
      maintenanceMode: json['maintenance_mode'] as bool? ?? false,
      defaultLanguage: json['default_language'] as String? ?? 'ar',
      baseUrl: json['base_url'] as String? ?? '',
      apiKey: json['api_key'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'app_name': appName,
      'logo_url': logoUrl,
      'contact_email': contactEmail,
      'contact_phone': contactPhone,
      'social_links': socialLinks,
      'maintenance_mode': maintenanceMode,
      'default_language': defaultLanguage,
      'base_url': baseUrl,
      'api_key': apiKey,
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
    maintenanceMode: false,
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
        maintenanceMode,
        defaultLanguage,
        baseUrl,
        apiKey,
      ];
}
