import 'dart:convert';
import 'dart:developer';


import 'package:canteen_pro/repositories/repositories.dart';
import 'package:dart_extensions_methods/dart_extension_methods.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:newmidx_biometric/newmidx_biometric.dart';

import '../../models/employee_biodata.dart';
import '../../models/member.dart';
import '../../models/network_result.dart';
import '../../network/repos/network_config.dart';
import '../../services/encryption_helper.dart';
import '../../services/finger_face_service/finger_face_plugin.dart';
import '../../services/palm_vein_plugin/palm_vein_service.dart';


class MembersProvider extends Notifier<List<Member>>{
  final _apiRepo = UserRepository();
  bool _setEnrollmentMode = false;
  bool get setEnrollmentMode => _setEnrollmentMode;
  bool _isFetchingUsers = false;
  bool get isFetchingUsers => _isFetchingUsers;
  bool _isRefreshing = false;
  bool get isRefreshing => _isRefreshing;
  Member? _currentMember;
  Member? get currentMember => _currentMember;
  UserSecurityItem? _currentEmployeeBioData;
  UserSecurityItem? get currentEmployeeBioData => _currentEmployeeBioData;
  List<EmployeeBioData> _currentEmployeeBioDataList = [];
  List<EmployeeBioData> get currentEmployeeBioDataList => _currentEmployeeBioDataList;


  int _currentPage = 1;
  int get currentPage => _currentPage;
  int _totalPages = 1;
  int get totalPages => _totalPages;


  @override
  List<Member> build() {
    return [];
  }

  Future<void> toggleEnrollmentMode(bool val) async {
    _setEnrollmentMode = val;
    state = state;
  }

  Future<void> setMember(Member? employee) async {
    _currentMember = employee;
    state = state;
  }

  void setEmployeeBioData(UserSecurityItem? employeeBioData) {
    _currentEmployeeBioData = employeeBioData;
    state = state;
  }

  void setEmployeeBioDataList(List<EmployeeBioData>? employeeBioDataList) {
    _currentEmployeeBioDataList = employeeBioDataList ?? [];
    state = state;
  }


  Future<String?> getMembers({ int page = 1}) async {
    _isFetchingUsers = true;
    try {
      final bodyList = await _apiRepo.fetchUsers(page: page);
      if (bodyList.items.isEmpty) {
        _isFetchingUsers = false;
        return 'No members found';
      }

      _currentPage = bodyList.currentPage;
      _totalPages = bodyList.totalPages;

      final empDataList = bodyList.items;
      log('empDataList: $empDataList');
      state = empDataList;
      _isFetchingUsers = false;
      return null;
    } catch (e, s) {
      log('Error in getAllDrivers', error: e, stackTrace: s);
      _isFetchingUsers = false;
      return e.toString();
    } finally {
      _isFetchingUsers = false;
    }
  }

  Future<String?> queryMembers({ int page = 1, String filter = ''}) async {
    _isRefreshing = true;
    try {
      final bodyList  = await _apiRepo.fetchUsers(page: page, filter: filter);

      if (bodyList.items.isEmpty) {
        return 'No members found';
      }

      _currentPage = bodyList.currentPage;
      _totalPages = bodyList.totalPages;

      final members = bodyList.items;

      state = members;
      return null;
    } catch (e, s) {
      log('Error in getAllDrivers', error: e, stackTrace: s);
      return e.toString();
    } finally {
      _isRefreshing = false;
    }
  }

  Future<List<EmployeeBioData>> parseStaffSecurity(Member member) async {
    try {
      final List<Map<String, dynamic>> staffSecurityData = [];
      final fingerData = member.fingerprintReference;
      final faceData = member.faceRecognitionReference;
      final nfcData = member.nfcReference;

      if (fingerData != null) {
        staffSecurityData.add({BioDataType.finger.code: fingerData});
      }

      if (faceData != null) {
        staffSecurityData.add({BioDataType.face.code: faceData});
      }

      if (nfcData != null) {
        staffSecurityData.add({BioDataType.nfc.code: nfcData});
      }

      final bioData = staffSecurityData.map((e) {
        final biodataType = e.keys.first;
        final biodataLabel = _getBioDataLabel(biodataType);

        return EmployeeBioData(
          employeeId: member.id,
          biodataType: biodataType,
          biodataLabel: biodataLabel,
          status: 'ACTIVE',
        );
      });
      _currentEmployeeBioDataList = bioData.toList();
      return bioData.toList();
    } catch (e, s) {
      log('Error parsing staff security data for member: ${member.fullName}', error: e, stackTrace: s);
      rethrow;
    }
  }

  String _getBioDataLabel(String biodataType) {
    if (biodataType == BioDataType.finger.code) {
      return BioDataLabel.finger.code;
    } else if (biodataType == BioDataType.face.code) {
      return BioDataLabel.face.code;
    } else if (biodataType == BioDataType.nfc.code) {
      return BioDataLabel.nfc.code;
    } else  {
      return BioDataLabel.rightPalm.code;
    }
  }


  Future<String?> importPalmTemplate(
      String employeeId,
      List<EmployeeBioData> empDataList,
      ) async {

    if (empDataList.isEmpty) {
      log('No palm template to import for employee: $employeeId');
      return null;
    }

    log('Importing palm template for employee: $employeeId');

    final palmData = empDataList.where((element) => element.biodataType == BioDataType.palm.code);
    final leftPalm = palmData.firstWhereOrNull((element) => element.biodataLabel == BioDataLabel.leftPalm.code);
    final rightPalm = palmData.firstWhereOrNull((element) => element.biodataLabel == BioDataLabel.rightPalm.code);

    final PalmTemplate export = PalmTemplate(
      userId: employeeId,
      leftIrFeature: leftPalm?.palmBioData?.palmFeature,
      rightIrFeature: rightPalm?.palmBioData?.palmFeature,
    );

    final importRes = await PalmVeinService().importTemplates([export]);

    if (importRes != null) {
      return importRes;
    }
    return null;
  }

  Future<String?> importFaceTemplates(List<EmployeeBioData> empDataList) async {
    List<FaceExportData> empDataLists = [];

    for (final empData in empDataList) {
      final decodedFeatureBytes = base64.decode(empData.palmBioData?.palmFeature ?? "");
      final decodedImageBytes = base64.decode( "");
      final importData = FaceExportData(
        userId: empData.employeeId,
        imageBytes: decodedImageBytes,
        featureBytes: decodedFeatureBytes,
      );
      empDataLists.add(importData);
    }
    final importRes = await FingerFaceService().importFaceTemplates(empDataLists);

    if (importRes != null) {
      return importRes;
    }
    return null;
  }

  Future<String?> postMemberFingerData(
      {
        List<LabeledPalmTemplate>? palmData,
        bool isUpdate = false
      }) async {
    if (_currentMember == null) {
      return 'Select an employee first';
    }

    final List<EmployeeBioData> bioDataList = [];

    _isRefreshing = true;

    try {
      final employeeId = _currentMember?.id ?? "";

      if (palmData != null) {
        for (final palmFeature in palmData) {
          log('irFeature: ${palmFeature.palmFeature}');
          final encryptedIrFeature = CryptoHelper.encryptString(
              palmFeature.palmFeature);
          final newData = EmployeeBioData(
              employeeId: employeeId,
              biodataTemplateBytes: BioDataType.palm.code.replaceAll('_FEATURE', ''),
              palmBioData: PalmBioData(
                palmFeature: encryptedIrFeature,
              ),
              biodataType: BioDataType.palm.code,
              biodataLabel: palmFeature.palmType == "LEFT"
                  ? BioDataLabel.leftPalm.code
                  : BioDataLabel.rightPalm.code,
              status: "ACTIVE"
          );

          bioDataList.add(newData);
        }
      }

      if (bioDataList.isEmpty) {
        return 'No palm template to update';
      }


      // final res = await _apiRepo.postEmployeeBioData(employeeId, isUpdate,
      //   isUpdate ? EmployeeBioData.toWebJsonUpdate(bioDataList)
      //       : EmployeeBioData.toWebJson(bioDataList)
      // );
      //
      //
      // if (res == null) {
      //   return 'An error occurred';
      // }
      //
      // if (res is Map && res.containsKey('__error')) {
      //   return res['__error'];
      // }

      return null;
    } catch (e, s) {
      log('Error in postEmployeeBioData', error: e, stackTrace: s);
      return 'An error occurred';
    } finally {
      _isRefreshing = false;
    }
  }


  void reset() {
    _currentMember = null;
    _currentEmployeeBioData = null;
    _currentPage = 1;
    _totalPages = 1;
    _isFetchingUsers = false;
    _isRefreshing = false;
    _setEnrollmentMode = false;
    state = [];
  }

  void resetCurrentMemberState() {
    _currentMember = null;
    _currentEmployeeBioData = null;
    _setEnrollmentMode = false;
  }
}

final userProvider = NotifierProvider<MembersProvider, List<Member>>(
      () => MembersProvider(),
);
