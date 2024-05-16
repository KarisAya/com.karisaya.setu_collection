import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import "../image_preview.dart";

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
  getImageUrls() async {
    return [
      'https://via.placeholder.com/600x800/2ECC71/FFFFFF',
      'https://via.placeholder.com/600x400/2ECC71/FFFFFF',
      'https://via.placeholder.com/600x400/2ECC71/FFFFFF',
      'https://via.placeholder.com/800x300/2ECC71/FFFFFF',
    ];
  }
}
