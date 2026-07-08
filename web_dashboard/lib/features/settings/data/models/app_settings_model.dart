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
      appName: json['appName']?.toString() ?? '',
      logoUrl: json['logoUrl']?.toString(),
      contactEmail: json['contactEmail']?.toString() ?? '',
      contactPhone: json['contactPhone']?.toString() ?? '',
      socialLinks: json['socialLinks'] != null
          ? Map<String, String>.from(json['socialLinks'] as Map)
          : {},
      maintenanceMode: json['maintenanceMode'] == true ||
          json['maintenanceMode'] == 'true' ||
          json['maintenanceMode'] == 1 ||
          json['maintenanceMode'] == '1',
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
      'maintenanceMode': maintenanceMode,
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
