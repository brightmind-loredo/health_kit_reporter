class Device {
  const Device(
    this.name,
    this.manufacturer,
    this.model,
    this.hardwareVersion,
    this.firmwareVersion,
    this.softwareVersion,
    this.localIdentifier,
    this.udiDeviceIdentifier,
  );

  final String name;
  final String manufacturer;
  final String model;
  final String hardwareVersion;
  final String firmwareVersion;
  final String softwareVersion;
  final String localIdentifier;
  final String udiDeviceIdentifier;

  Map<String, String> get map => {
        'name': name,
        'manufacturer': manufacturer,
        'model': model,
        'hardwareVersion': hardwareVersion,
        'firmwareVersion': firmwareVersion,
        'softwareVersion': softwareVersion,
        'localIdentifier': localIdentifier,
        'udiDeviceIdentifier': udiDeviceIdentifier,
      };

  Device.fromJson(Map<String, dynamic> json)
      : name = json['name'],
        manufacturer = json['manufacturer'],
        model = json['model'],
        hardwareVersion = json['hardwareVersion'],
        firmwareVersion = json['firmwareVersion'],
        softwareVersion = json['softwareVersion'],
        localIdentifier = json['localIdentifier'],
        udiDeviceIdentifier = json['udiDeviceIdentifier'];
}