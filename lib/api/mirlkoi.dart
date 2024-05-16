import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import "../image_preview.dart";

Dio dio = Dio();

var status = CurrentStatus();

class MirlKoi extends StatefulWidget {
  const MirlKoi({super.key});

  @override
  State<StatefulWidget> createState() => _MirlKoiState();
}

List<String> imageUrls = [];
int currentIndex = 0;

class _MirlKoiState extends ImageAPIState<MirlKoi> {
  _MirlKoiState()
      : super(
          api: "MirlKoi API",
          status: status,
        );
  @override
  getImageUrls() async {
    return [
      'https://via.placeholder.com/600x800/FF5733/FFFFFF',
      'https://via.placeholder.com/600x400/3498DB/FFFFFF',
      'https://via.placeholder.com/600x400/2ECC71/FFFFFF',
      'https://via.placeholder.com/800x300/F1C40F/FFFFFF',
    ];
  }
}
