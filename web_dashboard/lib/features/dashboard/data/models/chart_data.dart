import 'package:equatable/equatable.dart';

/// Generic data point for charts (e.g. user growth).
class ChartData extends Equatable {
  final String label;
  final double value;

  const ChartData({
    required this.label,
    required this.value,
  });

  factory ChartData.fromJson(Map<String, dynamic> json) {
    return ChartData(
      label: json['label'] as String? ?? '',
      value: (json['value'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'label': label,
      'value': value,
    };
  }

  @override
  List<Object?> get props => [label, value];
}

