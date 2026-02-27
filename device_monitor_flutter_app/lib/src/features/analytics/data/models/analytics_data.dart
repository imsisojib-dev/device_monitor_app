class AnalyticsData {
  final String deviceId;
  final AnalyzedPeriod analyzedPeriod;
  final List<Analysis> analyses;
  final OverallSummary overallSummary;

  AnalyticsData({
    required this.deviceId,
    required this.analyzedPeriod,
    required this.analyses,
    required this.overallSummary,
  });

  factory AnalyticsData.fromJson(Map<String, dynamic> json) {
    return AnalyticsData(
      deviceId: json['deviceId'] ?? '',
      analyzedPeriod: AnalyzedPeriod.fromJson(json['analyzedPeriod'] ?? {}),
      analyses: (json['analyses'] as List<dynamic>?)
          ?.map((e) => Analysis.fromJson(e))
          .toList() ??
          [],
      overallSummary: OverallSummary.fromJson(json['overallSummary'] ?? {}),
    );
  }
}

class AnalyzedPeriod {
  final String startDate;
  final String endDate;
  final int daysAnalyzed;

  AnalyzedPeriod({
    required this.startDate,
    required this.endDate,
    required this.daysAnalyzed,
  });

  factory AnalyzedPeriod.fromJson(Map<String, dynamic> json) {
    return AnalyzedPeriod(
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      daysAnalyzed: json['daysAnalyzed'] ?? 0,
    );
  }
}

class Analysis {
  final String type;
  final String title;
  final String description;
  final String severity;
  final String recommendation;
  final String lastUpdated;
  final Map<String, dynamic> data;

  Analysis({
    required this.type,
    required this.title,
    required this.description,
    required this.severity,
    required this.recommendation,
    required this.lastUpdated,
    required this.data,
  });

  factory Analysis.fromJson(Map<String, dynamic> json) {
    return Analysis(
      type: json['type'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      severity: json['severity'] ?? '',
      recommendation: json['recommendation'] ?? '',
      lastUpdated: json['lastUpdated'] ?? '',
      data: json['data'] ?? {},
    );
  }
}

class OverallSummary {
  final String deviceCondition;
  final int criticalIssues;
  final int warnings;
  final int improvements;
  final String topRecommendation;

  OverallSummary({
    required this.deviceCondition,
    required this.criticalIssues,
    required this.warnings,
    required this.improvements,
    required this.topRecommendation,
  });

  factory OverallSummary.fromJson(Map<String, dynamic> json) {
    return OverallSummary(
      deviceCondition: json['deviceCondition'] ?? '',
      criticalIssues: json['criticalIssues'] ?? 0,
      warnings: json['warnings'] ?? 0,
      improvements: json['improvements'] ?? 0,
      topRecommendation: json['topRecommendation'] ?? '',
    );
  }
}

// Helper classes for specific analysis types
class DeviceHealthScore {
  final int currentScore;
  final String trend;
  final int previousScore;
  final Map<String, int> breakdown;
  final double trendPercentage;
  final String status;

  DeviceHealthScore({
    required this.currentScore,
    required this.trend,
    required this.previousScore,
    required this.breakdown,
    required this.trendPercentage,
    required this.status,
  });

  factory DeviceHealthScore.fromJson(Map<String, dynamic> json) {
    return DeviceHealthScore(
      currentScore: json['currentScore'] ?? 0,
      trend: json['trend'] ?? '',
      previousScore: json['previousScore'] ?? 0,
      breakdown: Map<String, int>.from(json['breakdown'] ?? {}),
      trendPercentage: (json['trendPercentage'] ?? 0).toDouble(),
      status: json['status'] ?? '',
    );
  }
}

class ThermalDistribution {
  final int warm;
  final int nominal;
  final int cool;
  final int hot;

  ThermalDistribution({
    required this.warm,
    required this.nominal,
    required this.cool,
    required this.hot,
  });

  factory ThermalDistribution.fromJson(Map<String, dynamic> json) {
    return ThermalDistribution(
      warm: json['warm'] ?? 0,
      nominal: json['nominal'] ?? 0,
      cool: json['cool'] ?? 0,
      hot: json['hot'] ?? 0,
    );
  }

  int get total => warm + nominal + cool + hot;
}

class MemoryUsageDistribution {
  final int high;
  final int optimal;
  final int critical;
  final int moderate;

  MemoryUsageDistribution({
    required this.high,
    required this.optimal,
    required this.critical,
    required this.moderate,
  });

  factory MemoryUsageDistribution.fromJson(Map<String, dynamic> json) {
    return MemoryUsageDistribution(
      high: json['high'] ?? 0,
      optimal: json['optimal'] ?? 0,
      critical: json['critical'] ?? 0,
      moderate: json['moderate'] ?? 0,
    );
  }

  int get total => high + optimal + critical + moderate;
}