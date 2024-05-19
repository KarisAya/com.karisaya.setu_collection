import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import "../image_api.dart";

Dio dio = Dio();

class AnosuStatus extends CurrentStatus {
  AnosuStatus() : super();
  bool r18 = false;
  int num = 30;
  String? tag;
}

var status = AnosuStatus();

class Anosu extends StatefulWidget {
  const Anosu({super.key});

  @override
  State<StatefulWidget> createState() => _AnosuState();
}

class _AnosuState extends ImageAPIState<Anosu> {
  _AnosuState() : super(api: "Anosu API", status: status);
  @override
  Future<List<ImageUrl>> getImageUrls() async {
    String args = "num=${status.num}";
    if (status.r18) {
      args = "$args&r18=1";
    }
    if (status.tag != null) {
      args = "$args&keyword=${status.tag}";
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
              title: Text('请求图片数量: ${status.num}'),
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
                    status.num = numInt;
                  });
                },
              ),
              contentPadding: EdgeInsets.zero,
            ),
            ListTile(
              title: const Text('请求关键字'),
              subtitle: Text(status.tag ?? "不指定"),
              trailing: IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () async {
                  status.tag = await showDialog(
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
                    status.preUpdate();
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
