import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import "../image_api.dart";

Dio dio = Dio();

var status = CurrentStatus();

class Anosu extends StatefulWidget {
  const Anosu({super.key});

  @override
  State<StatefulWidget> createState() => _AnosuState();
}

class _AnosuState extends ImageAPIState<Anosu> {
  _AnosuState() : super(api: "Anosu API", status: status);
  @override
  Future<List<String>> getImageUrls() async {
    var resp = await dio.get("https://image.anosu.top/pixiv/json?num=5");
    return (resp.data as List).map((item) => item["url"] as String).toList();
  }
}
