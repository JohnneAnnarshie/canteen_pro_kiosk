
import 'dart:convert';

import 'package:flutter/material.dart';

import '../../models/network_result.dart';
import '../../models/request_type.dart';
import '../api_service.dart';
import '../api_urls.dart';
import '../auth_urls.dart';

class ApiRepo {
  ApiRepo({
    required this.apiService,
  });

  final ApiService apiService;

  Future<Map<String, dynamic>?> getUserInfo() async {
    if (idpBaseUrl.isNotEmpty) {
      final res =
          await apiService.request(endPoint: userInfoUrl, replaceBaseUrl: '');
      if (res.keys.first) {
        return res.values.first;
      }
    }
    return null;
  }

  Future<dynamic> getTripByCode(String code) async {
    final res =
        await apiService.request(
            endPoint: '',
            replaceBaseUrl: '$tripsByCodeUrl$code'
        );
    if (res.keys.first) {
      return res.values.first;
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
                  ?.whereType<Map<String, dynamic>>()
                  .map((e) => e['message']?.toString() ?? '')
                  .where((m) => m.isNotEmpty)
                  .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {}
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }

  Future<dynamic> updateTripStatus(
      String tripId,
      String action
      ) async {
    final body = {
      "action": action
    };

    final res =
    await apiService.request(
        requestType: RequestType.post,
        endPoint: '',
        replaceBaseUrl: '$tripsUrl/$tripId/trip-state',
        body: body
    );
    if (res.keys.first) {
      return res.values.first;
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
              ?.whereType<Map<String, dynamic>>()
              .map((e) => e['message']?.toString() ?? '')
              .where((m) => m.isNotEmpty)
              .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {}
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }


  Future<dynamic> getTripState(
      String tripId
      ) async {
    final res =
    await apiService.request(
        requestType: RequestType.get,
        endPoint: '',
        replaceBaseUrl: '$tripsUrl/$tripId/trip-state',
    );

    if (res.keys.first) {
      final resMap = res.values.first as Map<String, dynamic>?;
      return resMap?['tripStatus'];
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
              ?.whereType<Map<String, dynamic>>()
              .map((e) => e['message']?.toString() ?? '')
              .where((m) => m.isNotEmpty)
              .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {}
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }


  Future<dynamic> getDeviceBySerialNumber(String serial) async {
    final res =
        await apiService.request(
            endPoint: '',
            replaceBaseUrl: '$devicesBySerialNumberUrl$serial'
        );
    if (res.keys.first) {
      return res.values.first;
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
                  ?.whereType<Map<String, dynamic>>()
                  .map((e) => e['message']?.toString() ?? '')
                  .where((m) => m.isNotEmpty)
                  .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {}
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }

  Future<dynamic> getGlobalSettings() async {
    final companyReference = apiService.getCompanyReference();
    final res =
        await apiService.request(
            endPoint: '',
            replaceBaseUrl: '${moduleForGlobalSettingsUrl}companyReference=$companyReference'
        );
    if (res.keys.first) {
      final resMap = res.values.first as Map<String, dynamic>?;
      final bodyList = resMap?['items'] as List?;
      if (bodyList == null) {
        return {'__error': 'An error occurred'};
      }
      final bodyMap = bodyList.first as Map<String, dynamic>?;
      final globalSettings = bodyMap?['generalSettings'] as Map<String, dynamic>?;
      return globalSettings;
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
                  ?.whereType<Map<String, dynamic>>()
                  .map((e) => e['message']?.toString() ?? '')
                  .where((m) => m.isNotEmpty)
                  .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {}
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }

  //  "currentPage": "<integer>",
  //   "resultsPerPage": "<integer>",
  //   "totalPages": "<integer>",
  //   "totalResults": "<long>",

  Future<dynamic> getAllEmployees({int page = 1, String filter = ''}) async {
    //&filter=<string>&page=<integer>
    final res =
        await apiService.request(
            endPoint: '',
            replaceBaseUrl: '${allEmployeesUrl}&filter=$filter&page=$page&results=20'
        );
    if (res.keys.first) {
      final resMap = res.values.first as Map<String, dynamic>?;
      final currentPage = resMap?['currentPage'] as int?;
      final totalPages = resMap?['totalPages'] as int?;
      final totalResults = resMap?['totalResults'] as int?;
      final resultsPerPage = resMap?['resultsPerPage'] as int?;
      final items = resMap?['items'] as List?;
      final empty = items?.isEmpty ?? true;

      final bodyList = resMap?['items'] as List?;
      if (bodyList == null) {
        return {'__error': 'An error occurred'};
      }
      return NetworkResponse(
          currentPage: currentPage ?? 0,
          resultsPerPage: resultsPerPage ?? 0,
          totalPages: totalPages ?? 0,
          totalResults: totalResults ?? 0,
          items: bodyList,
          empty: empty
      );
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
                  ?.whereType<Map<String, dynamic>>()
                  .map((e) => e['message']?.toString() ?? '')
                  .where((m) => m.isNotEmpty)
                  .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {
        return {'__error': body?.toString() ?? 'An error occurred'};
      }
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }

  Future<dynamic> getEmployeeBioData(String employeeId) async {
    final res =
        await apiService.request(
            endPoint: '',
            replaceBaseUrl: '$employeeBiodataUrl?employeeId=$employeeId&biodataType=PALM_FEATURE'
        );
    if (res.keys.first) {
      final resMap = res.values.first as Map<String, dynamic>?;
      final currentPage = resMap?['currentPage'] as int?;
      final totalPages = resMap?['totalPages'] as int?;
      final totalResults = resMap?['totalResults'] as int?;
      final resultsPerPage = resMap?['resultsPerPage'] as int?;
      final items = resMap?['items'] as List?;
      final empty = items?.isEmpty ?? true;

      final bodyList = resMap?['items'] as List?;
      if (bodyList == null) {
        return {'__error': 'An error occurred'};
      }
      return NetworkResponse(
          currentPage: currentPage ?? 0,
          resultsPerPage: resultsPerPage ?? 0,
          totalPages: totalPages ?? 0,
          totalResults: totalResults ?? 0,
          items: bodyList,
          empty: empty
      );
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
                  ?.whereType<Map<String, dynamic>>()
                  .map((e) => e['message']?.toString() ?? '')
                  .where((m) => m.isNotEmpty)
                  .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {}
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }

  Future<dynamic> postEmployeeBioData(
      String employeeId,
      bool isUpdate,
      Map<String, dynamic> bioDataLList
      ) async {
    final res =
        await apiService.request(
            requestType: isUpdate ? RequestType.put : RequestType.post,
            endPoint: '',
            replaceBaseUrl: employeeBiodataUrl,
            body: bioDataLList
        );
    if (res.keys.first) {
      return res.values.first;
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
                  ?.whereType<Map<String, dynamic>>()
                  .map((e) => e['message']?.toString() ?? '')
                  .where((m) => m.isNotEmpty)
                  .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {}
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }


  Future<dynamic> postTransactionLogs(
      List<Map<String, dynamic>> transactionLog
      ) async {
    final res =
        await apiService.request(
            requestType: RequestType.post,
            endPoint: '',
            replaceBaseUrl: transactionLogsUrl,
            body: transactionLog
        );
    if (res.keys.first) {
      return res.values.first;
    } else {
      final body = res.values.first;
      try {
        if (body is Map && body.containsKey('errors')) {
          final errors = body['errors'] as List?;
          final messages = errors
                  ?.whereType<Map<String, dynamic>>()
                  .map((e) => e['message']?.toString() ?? '')
                  .where((m) => m.isNotEmpty)
                  .toList() ?? [];
          final message = messages.isNotEmpty ? messages.join('\n') : body.toString();
          return {'__error': message};
        }
      } catch (_) {}
      return {'__error': body?.toString() ?? 'An error occurred'};
    }
  }

  //{
  //   "note": "<string>",
  //   "serverAuthentication": "<integer>",
  //   "lastMatchingDate": "<dateTime>",
  //   "isAutoClocking": "<boolean>",
  //   "calculationBasis": "<integer>",
  //   "numberOfHours": "<integer>",
  //   "afterShiftStartAllowance": "<integer>",
  //   "afterShiftEndAllowance": "<integer>",
  //   "companyReference": "<string>",
  //   "matchingOption": "<integer>",
  //   "isSpecialDay": "<boolean>",
  //   "specialDays": {
  //     "days": [
  //       "<integer>",
  //       "<integer>"
  //     ],
  //     "shiftIds": [
  //       "<uuid>",
  //       "<uuid>"
  //     ]
  //   },
  //   "generalSettings": {
  //     "maxDriveTimePerWindow": "<integer>",
  //     "maxConsecutiveDriveTime": "<integer>",
  //     "maxTotalDriveTimeDaily": "<integer>",
  //     "minRestTimeBetweenWindows": "<integer>",
  //     "restTime": "<integer>",
  //     "speedLimit": "<integer>",
  //     "status": "ACTIVE"
  //   }
  // }


}


