class StatisticsData {
  final String id;
  final String title;
  final String category;
  final String description;
  final List<DataPoint> data;
  final String unit;
  final String source;
  final DateTime lastUpdate;

  StatisticsData({
    required this.id,
    required this.title,
    required this.category,
    required this.description,
    required this.data,
    required this.unit,
    required this.source,
    required this.lastUpdate,
  });

  factory StatisticsData.fromJson(Map<String, dynamic> json) {
    return StatisticsData(
      id: json['id'],
      title: json['title'],
      category: json['category'],
      description: json['description'],
      data: (json['data'] as List)
          .map((item) => DataPoint.fromJson(item))
          .toList(),
      unit: json['unit'],
      source: json['source'],
      lastUpdate: DateTime.parse(json['last_update']),
    );
  }
}

class DataPoint {
  final String label;
  final double value;
  final int year;
  final String? region;

  DataPoint({
    required this.label,
    required this.value,
    required this.year,
    this.region,
  });

  factory DataPoint.fromJson(Map<String, dynamic> json) {
    return DataPoint(
      label: json['label'],
      value: json['value'].toDouble(),
      year: json['year'],
      region: json['region'],
    );
  }
}

class Province {
  final String id;
  final String name;
  final String code;
  final Map<String, dynamic>? geoData;

  Province({
    required this.id,
    required this.name,
    required this.code,
    this.geoData,
  });

  factory Province.fromJson(Map<String, dynamic> json) {
    return Province(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      geoData: json['geo_data'],
    );
  }
}
