class DountChartModel {
  final String category;
  final double value;

  DountChartModel({required this.category, required this.value});

  factory DountChartModel.fromJson(Map<String, dynamic> json) {
    return DountChartModel(
      category: json['category'] ?? 'Unknown',
      value: (json['value'] ?? 0).toDouble(),
    );
  }
}
