import 'package:equatable/equatable.dart';

class VitalsEntity extends Equatable{
  int? id;
  DateTime? createdAt;
  DateTime? updatedAt;
  int thermalStatus = 0;
  int batteryLevel = 0;
  int memoryUsage = 0;
  DateTime? timestamp;

  VitalsEntity(
      {this.id,
        this.createdAt,
        this.updatedAt,
        this.thermalStatus = 0,
        this.batteryLevel = 0,
        this.memoryUsage = 0,
        this.timestamp,
      });

  VitalsEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    createdAt = DateTime.tryParse('${json['createdAt']}');
    updatedAt = DateTime.tryParse('${json['updatedAt']}');
    thermalStatus = int.tryParse('${json['thermalStatus']}')??0;
    batteryLevel = int.tryParse('${json['batteryLevel']}')??0;
    memoryUsage = int.tryParse('${json['memoryUsage']}')??0;
    timestamp = DateTime.tryParse('${json['timestamp']}');
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['createdAt'] = createdAt;
    data['updatedAt'] = updatedAt;
    data['thermalStatus'] = thermalStatus;
    data['batteryLevel'] = batteryLevel;
    data['memoryUsage'] = memoryUsage;
    data['timestamp'] = timestamp;
    return data;
  }

  @override
  List<Object?> get props => [id, thermalStatus, batteryLevel, memoryUsage];
}