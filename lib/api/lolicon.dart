import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import "../image_api.dart";

Dio dio = Dio();

class LoliconStatus extends CurrentStatus {
  LoliconStatus() : super();
  bool r18 = false;
  bool excludeAI = true;
  int num = 20;
  List<String> tag = [];
}

var status = LoliconStatus();

class Lolicon extends StatefulWidget {
  const Lolicon({super.key});

  @override
  State<StatefulWidget> createState() => _LoliconState();
}

class _LoliconState extends ImageAPIState<Lolicon> {
  _LoliconState() : super(api: "Lolicon API", status: status);
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
              title: Text('请求图片数量: ${status.num}'),
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
                    status.num = numInt;
                  });
                },
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('请求关键字'),
              subtitle: Text(status.tag.isEmpty ? "不指定" : status.tag.join(",")),
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
                    status.preUpdate();
                    status.tag = tag.split(" ");
                  });
                },
              ),
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: status.r18,
              onChanged: (bool flag) {
                setState(() {
                  status.preUpdate();
                  status.r18 = flag;
                });
              },
              title: const Text('开启 r18'),
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              value: status.excludeAI,
              onChanged: (bool flag) {
                setState(() {
                  status.excludeAI = flag;
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
