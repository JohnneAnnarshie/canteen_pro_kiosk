
enum BioDataLabel {
  finger("FINGER"),
  rightPalm("RIGHT_HAND"),
  leftPalm("LEFT_HAND"),
  face("FACE"),
  nfc("NFC");

  final String code;
  const BioDataLabel(this.code);
}

enum BioDataType {
  palm("PALM_FEATURE"),
  finger("FINGERPRINT"),
  face("FACE"),
  nfc("NFC_TAG");

  final String code;
  const BioDataType(this.code);
}


class EmployeeBioData {
  final String employeeId;
  final String? biodataTemplateBytes;
  final PalmBioData? palmBioData;
  final String biodataType;
  final String biodataLabel;
  final String status;

  const EmployeeBioData({
    required this.employeeId,
    this.biodataTemplateBytes,
    this.palmBioData,
    required this.biodataType,
    required this.biodataLabel,
    required this.status,
  });

  factory EmployeeBioData.fromJson(Map<String, dynamic> json) {
    return EmployeeBioData(
      employeeId: json['employeeId']?.toString() ?? '',
      biodataTemplateBytes: json['biodataTemplateBytes']?.toString() ?? '',
      palmBioData: PalmBioData.fromJson(json['palmBioData']),
      biodataType: json['biodataType']?.toString() ?? '',
      biodataLabel: json['biodataLabel']?.toString() ?? '',
      status: json['status']?.toString() ?? '',
    );
  }

  static List<EmployeeBioData> fromJsonList(List<dynamic> json) {
    return json.map((e) => EmployeeBioData.fromJson(e)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<EmployeeBioData> list) {
    return list.map((e) => e.toJson()).toList();
  }



  Map<String, dynamic> toJson() {
    return {
      'employeeId': employeeId,
      'biodataTemplateBytes': biodataTemplateBytes,
      'palmBioData': palmBioData?.toJson(),
      'biodataType': biodataType,
      'biodataLabel': biodataLabel,
      'status': status,
    };
  }




  EmployeeBioData copyWith({
    String? employeeId,
    String? biodataTemplateBytes,
    PalmBioData? palmBioData,
    String? biodataType,
    String? biodataLabel,
    String? status,
  }) {
    return EmployeeBioData(
      employeeId: employeeId ?? this.employeeId,
      biodataTemplateBytes: biodataTemplateBytes ?? this.biodataTemplateBytes,
      palmBioData: palmBioData ?? this.palmBioData,
      biodataType: biodataType ?? this.biodataType,
      biodataLabel: biodataLabel ?? this.biodataLabel,
      status: status ?? this.status,
    );
  }


  @override
  String toString() {
    return 'EmployeeBioData('
        'employeeId: $employeeId, '
        'biodataTemplateBytes: $biodataTemplateBytes, '
        'biodataType: $biodataType, '
        'biodataLabel: $biodataLabel'
        'status: $status'
        ')';
  }
}

class PalmBioData {
  final String? palmFeature;

  const PalmBioData({
    required this.palmFeature,
  });

  factory PalmBioData.fromJson(Map<String, dynamic> json) {
    return PalmBioData(
      palmFeature: json['palmFeature'],
    );
  }

  static List<PalmBioData> fromJsonList(List<dynamic> json) {
    return json.map((e) => PalmBioData.fromJson(e)).toList();
  }

  static List<Map<String, dynamic>> toJsonList(List<PalmBioData> list) {
    return list.map((e) => e.toJson()).toList();
  }

  Map<String, dynamic> toJson() {
    return {
      'palmFeature': palmFeature,
    };
  }

  PalmBioData copyWith({
    String? palmFeature,
  }) {
    return PalmBioData(
      palmFeature: palmFeature ?? this.palmFeature,
    );
  }
}