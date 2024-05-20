import "dart:io";
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:path_provider/path_provider.dart';

Logger logger = Logger();

class Settings {
  Settings(this.file);
  File file;
  Color seedColor = Colors.grey;
  String api = "Lolicon API";
  bool drawerImage = false;
  String drawerImageUrl = "https://moe.jitsu.top/img/?sort=pc";
  Map<String, Map> apiSettings = {};

  Settings.fromJson(Map<String, dynamic> json)
      : file = File(json['file'] as String),
        seedColor = Color(json['seedColor'] as int),
        api = json['api'] as String,
        drawerImage = json['drawerImage'] as bool,
        apiSettings = Map<String, Map>.from(json['apiSettings'] as Map);

  Map<String, dynamic> toJson() => {
        'file': file.path,
        'seedColor': seedColor.value,
        'api': api,
        'apiSettings': apiSettings,
        'drawerImage': drawerImage,
      };

  void save() async {
    final jsonString = jsonEncode(toJson());
    await file.writeAsString(jsonString);
  }

  static Future<Settings> load() async {
    WidgetsFlutterBinding.ensureInitialized();
    final directory = await getApplicationDocumentsDirectory();
    final file = File('${directory.path}/settings.json');
    if (file.existsSync()) {
      try {
        final jsonString = await file.readAsString();
        var settings = Settings.fromJson(jsonDecode(jsonString));
        settings.file = file;
        return settings;
      } catch (e) {
        logger.e(e);
      }
    }
    return Settings(file);
  }
}
