import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

extension NumExt on num? {
  SizedBox get hSpace => SizedBox(width: this?.toDouble() ?? 8.0);
  SizedBox get vSpace => SizedBox(height: this?.toDouble() ?? 8.0);

  String get toReal => NumberFormat('#,##0.00').format(this);

  String get toCurrency => NumberFormat.currency(locale: 'en_NG', symbol: 'GHS ').format(this);

  String get toCompactCurrency => NumberFormat.compactCurrency(locale: 'en_NG', symbol: 'GHS ').format(this);

}

extension DoubleTo2DP on double? {
  String get to2DP =>
      this == null ? 'Invalid' : NumberFormat('#,##0.00').format(this);
}


extension ToReal on num {

}

extension StringExt on String? {
  String get formattedDateText {
    // FORMAT : 2026-01-23T00:00:00
    if (this == null) {
      return 'N/A';
    } else {
      final dateTime = DateTime.tryParse(this!);
      if (dateTime == null) {
        return 'N/A';
      }
      final date = DateFormat('dd MMM yyyy').format(dateTime);
      return date;
    }
  }

  String get normalizedDate {
    // FORMAT : 2026-01-23T00:00:00
    if (this == null) {
      return 'N/A';
    } else {
      final dateTime = DateTime.tryParse(this!);
      if (dateTime == null) {
        return 'N/A';
      }

      if (dateTime.isSameDay) {
        return 'Today';
      }

      final date = DateFormat('EEE, dd MMM yyyy').format(dateTime);
      return date;
    }
  }

  String get normalizedDateWithTime {
    // FORMAT : 2026-01-23T00:00:00
    if (this == null) {
      return 'N/A';
    } else {
      final dateTime = DateTime.tryParse(this!);
      if (dateTime == null) {
        return 'N/A';
      }

      if (dateTime.isSameDay) {
        return 'Today';
      }

      final date = DateFormat('EEE, dd MMM yyyy, hh:mm a').format(dateTime);
      return date;
    }
  }

  DateTime? get toDate {
    if (this == null) {
      return null;
    } else {
      return DateTime.parse(this!);
    }
  }

  String get normalizedTime {
    if (this == null) {
      return "N/A";
    } else {
      final dateTime = DateTime.tryParse(this!);
      if (dateTime == null) {
        return "N/A";
      }
      final time = DateFormat('hh:mm a').format(dateTime);
      return time;
    }
  }
}

extension DateExt on DateTime? {
  String get formatted {
    if (this == null) {
      return 'N/A';
    } else {
      final date = DateFormat('dd MMM yyyy').format(this!);
      final time = DateFormat('hh:mm a').format(this!);

      return "$date, $time";
    }
  }

  String get dayFormat {
    if (this == null) {
      return 'N/A';
    } else {
      final date = DateFormat('dd MMM yyyy').format(this!);
      return date;
    }
  }

  String get formattedWithDay {
    if (this == null) {
      return 'N/A';
    } else {
      final date = DateFormat('EEE, dd MMM yyyy, hh:mm a').format(this!);
     /// final time = DateFormat('hh:mm a').format(this!);

      return date;
    }
  }

  bool get isSameDay {
    if (this == null) {
      return false;
    }
    if (DateTime.now().day == this!.day &&
        DateTime.now().month == this!.month &&
        DateTime.now().year == this!.year) {
      return true;
    } else {
      return false;
    }
  }

  bool get isYesterday {
    if (this == null) {
      return false;
    }
    if (DateTime.now().day - 1 == this!.day &&
        DateTime.now().month == this!.month &&
        DateTime.now().year == this!.year) {
      return true;
    } else {
      return false;
    }
  }

  String get dayAsText {
    if(this == null) {
      return "";
    }
    switch(this!.weekday) {
      case 1:
        return "Monday";
        case 2:
        return "Tuesday";
        case 3:
        return "Wednesday";
        case 4:
        return "Thursday";
        case 5:
        return "Friday";
        case 6:
        return "Saturday";
        case 7:
        return "Sunday";
        default:
          return "";
    }
  }

  String? get formattedTime {
    if (this == null) {
      return null;
    } else {
      final time = DateFormat('hh:mm').format(this!);
      return time;
    }
  }

  String? get formattedTimeAMpM {
    if (this == null) {
      return null;
    } else {
      final time = DateFormat('hh:mm a').format(this!);
      return time;
    }
  }
}