class DeviceEntity {
  int? id;
  String? deviceId;
  String? model;
  String? brand;
  String? osName;
  String? osVersion;
  String? androidId;
  String? identifierForVendor;

  DeviceEntity(
      {this.id,
        this.deviceId,
        this.model,
        this.brand,
        this.osName,
        this.osVersion,
        this.androidId,
        this.identifierForVendor,
      });

  DeviceEntity.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    deviceId = json['deviceId'];
    model = json['model'];
    brand = json['brand'];
    osName = json['osName'];
    osVersion = json['osVersion'];
    androidId = json['androidId'];
    identifierForVendor = json['identifierForVendor'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['id'] = id;
    data['deviceId'] = deviceId;
    data['model'] = model;
    data['brand'] = brand;
    data['osName'] = osName;
    data['osVersion'] = osVersion;
    data['androidId'] = androidId;
    data['identifierForVendor'] = identifierForVendor;
    return data;
  }
}