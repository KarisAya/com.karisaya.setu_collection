import 'package:flutter/material.dart';
import "test.dart";
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
  String title = "Anosu";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Theme.of(context).colorScheme.primary,
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.settings))
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
                  backgroundImage:
                      NetworkImage("https://docs.anosu.top/favicon.ico"),
                  backgroundColor: Colors.transparent,
                ),
                onTap: () {
                  _changeBody('Anosu');
                }),
            ListTile(
                title: const Text('MirlKoi API'),
                trailing: const CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://dev.iw233.cn/css/ec43126fgy1h4604r4bk1j21801801kx.jpg"),
                  backgroundColor: Colors.transparent,
                ),
                onTap: () {
                  _changeBody('MirlKoi API');
                }),
            ListTile(
                title: const Text('Lolicon API'),
                trailing: const CircleAvatar(
                  backgroundImage: NetworkImage(
                      "https://avatars.githubusercontent.com/u/24877906?v=4"),
                  backgroundColor: Colors.transparent,
                ),
                onTap: () {
                  _changeBody('Lolicon API');
                }),
            ListTile(
                title: const Text('Test'),
                trailing: const Icon(Icons.image),
                onTap: () {
                  _changeBody('Test');
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
      body: _getBody(title),
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
      case 'Anosu':
        return const Anosu();
      case 'MirlKoi API':
        return const MirlKoi();
      case 'Lolicon API':
        return ImageCarouselPage2();
      case 'Test':
        return ImageCarouselPage2();

      default:
        return const Center(
          child: Text('未知页面'),
        );
    }
  }
}
