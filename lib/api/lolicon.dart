import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import "../image_api.dart";

Dio dio = Dio();

class LoliconStatus extends CurrentStatus {
  @override
  final String key = "Lolicon API";
  @override
  final Map<String, dynamic> defaultSettings = {
    "r18": false,
    "excludeAI": true,
    "num": 20,
    "tag": [],
  };

  bool get r18 => map["r18"];
  set r18(bool value) => map["r18"] = value;
  bool get excludeAI => map["excludeAI"];
  set excludeAI(bool value) => map["excludeAI"] = value;
  int get num => map["num"];
  set num(int value) => map["num"] = value;
  List<String> get tag => map["tag"];
  set tag(List<String> value) => map["tag"] = value;
}

final LoliconStatus myStatus = LoliconStatus();

class Lolicon extends ImageAPI {
  const Lolicon(super.settings, {super.key});
  @override
  ImageAPIState<Lolicon> createState() => _LoliconState();
}

class _LoliconState extends ImageAPIState<Lolicon> {
  @override
  final LoliconStatus status = myStatus;

  @override
  Future<List<ImageUrl>> getImageUrls() async {
    var data = {
      "r18": status.r18 ? 1 : 0,
      "num": status.num,
      "excludeAI": status.excludeAI,
      "size": ["original", "regular"]
    };
    if (status.tag.isNotEmpty) data["tag"] = status.tag;

    var resp = await dio.post("https://api.lolicon.app/setu/v2", data: data);
    return (resp.data["data"] as List).map((item) {
      return ImageUrl(
        item["urls"]["regular"] as String,
        original: item["urls"]["original"] as String,
      );
    }).toList();
  }
}

class LoliconSetting extends StatefulWidget {
  const LoliconSetting({super.key});

  @override
  State<StatefulWidget> createState() => _LoliconSettingState();
}

class _LoliconSettingState extends State<LoliconSetting> {
  TextEditingController numTEC = TextEditingController();
  TextEditingController tagTEC = TextEditingController();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Lolicon API 设置'),
      content: SingleChildScrollView(
        padding: EdgeInsets.zero,
        child: ListBody(
          children: [
            ListTile(
              title: Text('请求图片数量: ${myStatus.num}'),
              subtitle: const Text("1-20"),
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
              subtitle:
                  Text(myStatus.tag.isEmpty ? "不指定" : myStatus.tag.join(",")),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  String tag = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return buildAlertDialog(
                          context,
                          tagTEC,
                          title: const Text("请求关键字"),
                          hintText: "使用空格隔开参数",
                        );
                      });
                  setState(() {
                    myStatus.preUpdate();
                    myStatus.tag = tag.split(" ");
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
            SwitchListTile(
              value: myStatus.excludeAI,
              onChanged: (bool flag) {
                setState(() {
                  myStatus.excludeAI = flag;
                });
              },
              title: const Text('排除AI创作'),
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
