import 'package:flutter/material.dart';
import "package:flutter/widgets.dart";
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "api/lolicon.dart";
import "api/anosu.dart";
import "api/mirlkoi.dart";
import "download.dart";
import "setting.dart";

const title = "Setu Collection";
void main() async {
  var settings = await Settings.load();
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (context) => AppSettings(settings)),
    ],
    child: MyApp(settings),
  ));
}

class AppSettings with ChangeNotifier {
  AppSettings(this.settings);
  final Settings settings;

  void setSeedColor(Color color) {
    settings.seedColor = color;
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp(this.settings, {super.key});
  final Settings settings;
  @override
  Widget build(BuildContext context) {
    return Consumer<AppSettings>(builder: (context, appSettings, child) {
      return MaterialApp(
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: settings.seedColor),
          useMaterial3: true,
        ),
        home: MyHomePage(settings),
      );
    });
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage(this.settings, {super.key});
  final Settings settings;
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  _MyHomePageState();
  late String title;

  @override
  void initState() {
    title = widget.settings.api;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    DrawerHeader drawerHeader = widget.settings.drawerImage
        ? DrawerHeader(
            decoration: BoxDecoration(
              image: DecorationImage(
                  image: NetworkImage(widget.settings.drawerImageUrl),
                  fit: BoxFit.cover),
            ),
            child: Container(),
          )
        : DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: const Center(
              child: Text("随机涩图 API 合集",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  )),
            ),
          );

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
            drawerHeader,
            ListTile(
                leading: const CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      "https://cdn.jitsu.top/img/home/favicon.ico"),
                  backgroundColor: Colors.transparent,
                ),
                trailing: const Text('Anosu API'),
                onTap: () {
                  _changeBody('Anosu API');
                }),
            ListTile(
                leading: const CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      "https://dev.iw233.cn/css/ec43126fgy1h4604r4bk1j21801801kx.jpg"),
                  backgroundColor: Colors.transparent,
                ),
                trailing: const Text('MirlKoi API'),
                onTap: () {
                  _changeBody('MirlKoi API');
                }),
            ListTile(
                leading: const CircleAvatar(
                  backgroundImage: CachedNetworkImageProvider(
                      "https://avatars.githubusercontent.com/u/24877906?v=4"),
                  backgroundColor: Colors.transparent,
                ),
                trailing: const Text('Lolicon API'),
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
            ListTile(
                title: const Text("设置"),
                trailing: const Icon(Icons.settings),
                onTap: () {
                  // 关闭Drawer
                  Navigator.pop(context);
                  // 导航到新页面
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SettingPage()),
                  );
                })
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

class SettingPage extends StatefulWidget {
  const SettingPage({super.key});
  @override
  State<SettingPage> createState() => _SettingPageState();
}

class _SettingPageState extends State<SettingPage> {
  @override
  Widget build(BuildContext context) {
    Container colorCard(Color color) => Container(
          width: 30.0,
          height: 30.0,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        );

    return Scaffold(
        appBar: AppBar(
          title: const Text('设置'),
          backgroundColor: Theme.of(context).colorScheme.primary,
        ),
        body: Consumer<AppSettings>(builder: (context, appSettings, child) {
          return ListView(children: [
            ListTile(
              title: const Text("主题色"),
              trailing: PopupMenuButton<Color>(
                onSelected: (selectedValue) {
                  appSettings.setSeedColor(selectedValue);
                  appSettings.settings.save();
                },
                itemBuilder: (context) {
                  return [
                    PopupMenuItem(
                      value: Colors.grey,
                      child: colorCard(Colors.grey),
                    ),
                    PopupMenuItem<Color>(
                      value: Colors.blue,
                      child: colorCard(Colors.blue),
                    ),
                    PopupMenuItem(
                      value: Colors.orange,
                      child: colorCard(Colors.orange),
                    ),
                    PopupMenuItem(
                      value: Colors.green,
                      child: colorCard(Colors.green),
                    ),
                    PopupMenuItem(
                      value: Colors.black,
                      child: colorCard(Colors.black),
                    ),
                    PopupMenuItem(
                      value: Colors.deepPurple,
                      child: colorCard(Colors.deepPurple),
                    ),
                  ];
                },
                icon: Container(
                  width: 30.0,
                  height: 30.0,
                  decoration: BoxDecoration(
                    color: appSettings.settings.seedColor,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
            ListTile(
              title: const Text("首页API"),
              trailing: PopupMenuButton<String>(
                  onSelected: (selectedValue) {
                    setState(() {
                      appSettings.settings.api = selectedValue;
                      appSettings.settings.save();
                    });
                  },
                  icon: Text(appSettings.settings.api),
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: "Anosu API",
                        child: Text("Anosu API"),
                      ),
                      const PopupMenuItem(
                        value: "MirlKoi API",
                        child: Text("MirlKoi API"),
                      ),
                      const PopupMenuItem(
                        value: "Lolicon API",
                        child: Text("Lolicon API"),
                      ),
                    ];
                  }),
            ),
            SwitchListTile(
              title: const Text('开启侧边栏头图'),
              value: appSettings.settings.drawerImage,
              onChanged: (bool flag) {
                setState(() {
                  appSettings.settings.drawerImage = flag;
                  appSettings.settings.save();
                });
              },
              activeColor: Theme.of(context).colorScheme.primary,
              inactiveThumbColor: Colors.grey,
              inactiveTrackColor: Colors.grey[300],
            ),
          ]);
        }));
  }
}
