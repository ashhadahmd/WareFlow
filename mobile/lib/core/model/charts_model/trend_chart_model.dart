class TrendChartModel {
  List<String>? labels;
  List<double>? value;

  TrendChartModel({this.labels, this.value});

  // ✅ SAHI TAREEQA: JSON se Model banane ke liye
  TrendChartModel.fromJson(Map<String, dynamic> json) {
    // 1. Dynamic list ko pakro, har item ko String banao, aur List<String> mein save karo
    if (json['labels'] != null) {
      labels = (json['labels'] as List).map((e) => e.toString()).toList();
    }

    // 2. Dynamic list ko pakro, har item ko number(num) maan kar double banao
    if (json['data'] != null) {
      value = (json['data'] as List)
          .map((item) => (item as num).toDouble())
          .toList();
    }
  }

  // Model se wapas JSON banane ke liye
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['labels'] = labels;
    data['data'] = value;
    return data;
  }
}
