import 'dart:convert';
import 'dart:math';

import 'package:uuid/uuid.dart';

extension StringExtension on String? {
  bool get nullOrEmpty => this == null || this!.isEmpty;

  bool get notNullOrEmpty => !nullOrEmpty;
}

class StringUtil {
  static String generateUid() {
    return const Uuid().v4();
  }

  static String getRandomString({int length = 8}) {
    final random = Random();
    const availableChars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    final randomString = List.generate(length,
            (index) => availableChars[random.nextInt(availableChars.length)])
        .join();
    return randomString;
  }

  static String normalize(String text) {
    return text
        .toLowerCase()
        .replaceAll(RegExp(r'[^\u4e00-\u9fa5a-z0-9]+'), '');
  }

  static bool isUid(String uid) {
    return RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$')
        .hasMatch(uid);
  }

  static String replaceLineBreak(String str) {
    return str.replaceAll(RegExp(r"\r\n"), "<br/>");
  }

  static String limitString(String str, {int limit = 30}) {
    return str.length > limit ? str.substring(0, limit) : str;
  }

  static String clearBlank(String str, {bool keepOne = true}) {
    return str.trim().replaceAll(RegExp(r"\s+"), keepOne ? " " : "");
  }

  static String clearBreak(String str) {
    return str.split('\n').where((line) => line.trim().isNotEmpty).join('');
  }

  static String clearEmptyLines(String str) {
    return str.split('\n').where((line) => line.trim().isNotEmpty).join('\n');
  }

  static String formatCount(int count) {
    if (count < 10000) {
      return count.toString();
    } else {
      return "${(count / 10000).toStringAsFixed(1)}万";
    }
  }

  static Map<String, dynamic> parseJson(String jsonStr) {
    return jsonDecode(jsonStr);
  }

  static List<dynamic> parseJsonList(String jsonStr) {
    return jsonDecode(jsonStr);
  }

  static bool isNotEmpty(String? str) {
    return str != null && str.isNotEmpty;
  }

  static bool isEmpty(String? str) {
    return str == null || str.isEmpty;
  }

  static String processEmpty(String? str, {String defaultValue = ""}) {
    return isEmpty(str) ? defaultValue : str!;
  }
}
