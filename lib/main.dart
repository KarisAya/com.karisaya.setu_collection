import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "api/lolicon.dart";
import "api/anosu.dart";
import "api/mirlkoi.dart";
import "download.dart";

void main() => runApp(const MyApp());

const title = "Setu Collection";

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: title,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        useMaterial3: true,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});
  @override
  State<StatefulWidget> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String title = "Anosu API";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => _getSetting(title),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                  image: DecorationImage(
                image: NetworkImage("https://moe.jitsu.top/img/?sort=pc"),
                fit: BoxFit.cover,
              )),
              child: Center(
                  child: Text("动漫图API合集",
                      style: TextStyle(
                        color: Colors.white, // 文本颜色
                        fontSize: 24,
                        shadows: <Shadow>[
                          Shadow(
                            offset: Offset(1, 1), // 阴影偏移量
                            blurRadius: 3.0, // 模糊半径
                            color: Colors.black, // 阴影颜色
                          ),
                        ],
                      ))),
            ),
            ListTile(
                title: const Text('Anosu API'),
                trailing: const CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      "https://docs.anosu.top/favicon.ico"),
                  backgroundColor: Colors.transparent,
                ),
                onTap: () {
                  _changeBody('Anosu API');
                }),
            ListTile(
                title: const Text('MirlKoi API'),
                trailing: const CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      "https://dev.iw233.cn/css/ec43126fgy1h4604r4bk1j21801801kx.jpg"),
                  backgroundColor: Colors.transparent,
                ),
                onTap: () {
                  _changeBody('MirlKoi API');
                }),
            ListTile(
                title: const Text('Lolicon API'),
                trailing: const CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      "https://avatars.githubusercontent.com/u/24877906?v=4"),
                  backgroundColor: Colors.transparent,
                ),
                onTap: () {
                  _changeBody('Lolicon API');
                }),
            const Divider(),
            ListTile(
                title: const Text("下载队列"),
                trailing: const Icon(Icons.download),
                onTap: () {
                  // 关闭Drawer
                  Navigator.pop(context);
                  // 导航到新页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const DownloadQueuePage()),
                  );
                }),
            const ListTile(
              title: Text("设置"),
              trailing: Icon(Icons.settings),
            )
          ],
        ),
      ),
      body: SingleChildScrollView(child: _getBody(title)),
    );
  }

  void _changeBody(String bodyName) {
    setState(() {
      title = bodyName;
    });
    Navigator.pop(context);
  }

  // 根据当前主体内容返回相应的Widget
  Widget _getBody(String bodyName) {
    title = bodyName;
    switch (bodyName) {
      case 'Anosu API':
        return const Anosu();
      case 'MirlKoi API':
        return const MirlKoi();
      case 'Lolicon API':
        return const Lolicon();
      default:
        return const Center(
          child: Text('未知页面'),
        );
    }
  }

  Widget _getSetting(String bodyName) {
    switch (bodyName) {
      case 'Anosu API':
        return const AnosuSetting();
      case 'MirlKoi API':
        return const MirlKoiSetting();
      case 'Lolicon API':
        return const LoliconSetting();
      default:
        return const Center(
          child: Text('未知页面'),
        );
    }
  }
}
