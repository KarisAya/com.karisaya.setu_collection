import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import "../image_api.dart";

Dio dio = Dio();

class MirlKoiStatus extends CurrentStatus {
  @override
  final String key = "MirlKoi API";
  @override
  final Map<String, dynamic> defaultSettings = {
    "num": 100,
    "tag": "random",
  };

  int get num => map["num"];
  set num(int value) {
    map["num"] = value;
    settings.save();
  }

  String get tag => map["tag"];
  set tag(String value) {
    map["tag"] = value;
    settings.save();
  }
}

final MirlKoiStatus myStatus = MirlKoiStatus();

class MirlKoi extends ImageAPI {
  MirlKoi({super.key});
  @override
  final MirlKoiStatus status = myStatus;
  @override
  ImageAPIState<MirlKoi> createState() => _MirlKoiState();
}

List<String> imageUrls = [];
int currentIndex = 0;

class _MirlKoiState extends ImageAPIState<MirlKoi> {
  @override
  getImageUrls() async {
    String args = "type=json&num=${myStatus.num}&sort=${myStatus.tag}";
    var resp = await dio.get("https://iw233.cn/api.php?$args");
    return (resp.data["pic"] as List)
        .map((item) => ImageUrl(item as String))
        .toList();
  }
}

class MirlKoiSetting extends StatefulWidget {
  const MirlKoiSetting({super.key});

  @override
  State<StatefulWidget> createState() => _MirlKoiSettingState();
}

class _MirlKoiSettingState extends State<MirlKoiSetting> {
  TextEditingController numTEC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('MirlKoi API 设置'),
      content: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: ListBody(
          children: [
            ListTile(
              title: Text('请求图片数量: ${myStatus.num}'),
              subtitle: const Text("1-100"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  String? result = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return buildAlertDialog(
                          context,
                          numTEC,
                          title: const Text("请求图片数量"),
                        );
                      });
                  if (result == null) return;
                  int? numInt = int.tryParse(result);
                  if (numInt == null) return;
                  if (numInt < 0 || numInt > 100) return;
                  setState(() {
                    myStatus.num = numInt;
                  });
                },
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('选择图库'),
              subtitle: Text(myStatus.tag),
              trailing: PopupMenuButton<String>(
                onSelected: (selectedValue) {
                  if (selectedValue == myStatus.tag) return;
                  setState(() {
                    myStatus.preUpdate();
                    myStatus.tag = selectedValue;
                  });
                },
                itemBuilder: (context) {
                  return [
                    const PopupMenuItem<String>(
                        value: 'random', child: Text('全部')),
                    const PopupMenuItem<String>(
                        value: 'iw233', child: Text('无色图')),
                    const PopupMenuItem<String>(
                        value: 'top', child: Text('推荐')),
                    const PopupMenuItem<String>(
                        value: 'yin', child: Text('银发')),
                    const PopupMenuItem<String>(
                        value: 'cat', child: Text('兽耳')),
                    const PopupMenuItem<String>(
                        value: 'xing', child: Text('星空')),
                    const PopupMenuItem<String>(
                        value: 'mp', child: Text('竖屏壁纸')),
                    const PopupMenuItem<String>(
                        value: 'pc', child: Text('横屏壁纸')),
                  ];
                },
                icon: const Icon(Icons.edit),
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.pop(context); // 关闭对话框
          },
          child: const Text('确认'),
        ),
      ],
    );
  }
}
