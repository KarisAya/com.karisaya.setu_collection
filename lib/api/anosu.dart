import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import "../image_api.dart";

Dio dio = Dio();

class AnosuStatus extends CurrentStatus {
  @override
  final String key = "Anosu API";
  @override
  final Map<String, dynamic> defaultSettings = {
    "r18": false,
    "num": 30,
    "tag": "",
  };

  bool get r18 => map["r18"];
  set r18(bool value) {
    map["r18"] = value;
    settings.save();
  }

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

final AnosuStatus myStatus = AnosuStatus();

class Anosu extends ImageAPI {
  Anosu({super.key});
  @override
  final AnosuStatus status = myStatus;
  @override
  ImageAPIState<Anosu> createState() => _AnosuState();
}

class _AnosuState extends ImageAPIState<Anosu> {
  @override
  Future<List<ImageUrl>> getImageUrls() async {
    String args = "num=${myStatus.num}";
    if (myStatus.r18) {
      args = "$args&r18=1";
    }
    if (myStatus.tag != "") {
      args = "$args&keyword=${myStatus.tag}";
    }
    var resp = await dio.get("https://image.anosu.top/pixiv/json?$args");
    return (resp.data as List)
        .map((item) => ImageUrl(item["url"] as String))
        .toList();
  }
}

class AnosuSetting extends StatefulWidget {
  const AnosuSetting({super.key});
  @override
  State<StatefulWidget> createState() => _AnosuSettingState();
}

class _AnosuSettingState extends State<AnosuSetting> {
  TextEditingController numTEC = TextEditingController();
  TextEditingController tagTEC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Anosu API 设置'),
      content: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: ListBody(
          children: [
            ListTile(
              title: Text('请求图片数量: ${myStatus.num}'),
              subtitle: const Text("1-30"),
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
                  if (numInt < 0 || numInt > 30) return;
                  setState(() {
                    myStatus.num = numInt;
                  });
                },
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('请求关键字'),
              subtitle: Text(myStatus.tag.isEmpty ? "不指定" : myStatus.tag),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  myStatus.tag = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return buildAlertDialog(
                          context,
                          tagTEC,
                          title: const Text("请求关键字"),
                          hintText: "使用|隔开参数",
                        );
                      });
                  setState(() {
                    myStatus.preUpdate();
                  });
                },
              ),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: myStatus.r18,
              onChanged: (bool flag) {
                setState(() {
                  myStatus.preUpdate();
                  myStatus.r18 = flag;
                });
              },
              title: const Text('开启 r18'),
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
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
