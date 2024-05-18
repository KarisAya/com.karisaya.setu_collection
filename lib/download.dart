import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

Dio dio = Dio();

MethodChannel _channel = const MethodChannel(
  'com.karisaya.setu_collection/get_public_dir',
);

Future<String?> get picturesPath async {
  try {
    final String result = await _channel.invokeMethod('getPicturesPath');
    return result;
  } catch (e) {
    throw PlatformException(
      code: 'UNAVAILABLE',
      message: 'Failed to get Pictures directory',
      details: e,
    );
  }
}

class DownloadManager {
  late String? path;
  late String? a;
  List<DownloadTask> tasks = [];
  DownloadManager() {
    init();
    // _tasks = cache
  }

  void init() async {
    path = await picturesPath;
  }

  void download(String url, String name) {
    if (path == null) return;
    print(path);
    var task = DownloadTask(url: url, name: name, path: path!);
    tasks.add(task);
    task.start();
  }
}

DownloadManager downloadManager = DownloadManager();

typedef ProgressCallback = void Function(int current, int total);

class DownloadTask {
  DownloadTask({required this.url, required this.name, required this.path});

  /// 0 未开始
  ///
  /// 1 正在下载
  ///
  /// 2 已完成
  ///
  /// 3 暂停
  int status = 0;

  final String url;
  final String name;
  final String path;
  String get savePath => "$path/$name";
  ProgressCallback? onReceiveProgress;

  void start() {
    status = 1;
    dio.download(url, savePath, onReceiveProgress: (int current, int total) {
      if (onReceiveProgress != null) onReceiveProgress!(current, total);
      if (current >= total) {
        status = 2;
      }
      ;
    });
  }

  void stop() {
    status = 3;
  }

  void cancel() {
    status = status == 2 ? 2 : 0;
  }
}

class DownloadProgress extends StatefulWidget {
  const DownloadProgress({super.key, required this.task});
  final DownloadTask task;

  @override
  State<DownloadProgress> createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<DownloadProgress> {
  double progress = 0.0;

  void listenProgress(int current, int total) {
    setState(() {
      progress = current / total;
    });
  }

  @override
  Widget build(BuildContext context) {
    Icon icon;
    Widget subtitle;
    VoidCallback? onPressed;
    switch (widget.task.status) {
      case (0):
        {
          icon = const Icon(Icons.file_download);
          subtitle = const Text('未开始');
          onPressed = () {};
        }
      case (1):
        {
          widget.task.onReceiveProgress = listenProgress;
          icon = const Icon(Icons.pause);
          subtitle = LinearProgressIndicator(value: progress);
          onPressed = () {
            setState(() {
              widget.task.stop();
            });
          };
        }
      case (2):
        {
          icon = const Icon(Icons.download_done);
          subtitle = const Text('下载完成');
        }
      case (3):
        {
          icon = const Icon(Icons.play_arrow);
          subtitle = const Text('暂停');
          onPressed = () {
            setState(() {
              widget.task.start();
            });
          };
        }
      default:
        {
          widget.task.onReceiveProgress = null;
          icon = const Icon(Icons.delete);
          subtitle = const Text('未知状态');
        }
    }
    return ListTile(
      title: Text(widget.task.name),
      subtitle: subtitle,
      trailing: IconButton(
        icon: icon,
        onPressed: onPressed,
      ),
      onLongPress: () {
        print("xxx");
      },
    );
  }

  @override
  void dispose() {
    widget.task.onReceiveProgress = null;
    super.dispose();
  }
}

class DownloadQueuePage extends StatefulWidget {
  const DownloadQueuePage({super.key});

  @override
  State<DownloadQueuePage> createState() => _DownloadQueuePageState();
}

class _DownloadQueuePageState extends State<DownloadQueuePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("下载"),
        actions: [
          IconButton(
              onPressed: () {
                setState(() {
                  downloadManager.tasks.removeWhere(
                      (task) => task.status == 0 || task.status == 2);
                });
              },
              icon: const Text("清空列表"))
        ],
      ),
      body: ListView.builder(
        itemCount: downloadManager.tasks.length,
        itemBuilder: (BuildContext context, int index) {
          final task = downloadManager.tasks[index];
          return Dismissible(
            key: ValueKey(task),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              task.cancel();
              downloadManager.tasks.removeWhere((task) => task.status == 0);
            },
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.only(left: 20.0),
              child: const Icon(Icons.delete),
            ),
            child: DownloadProgress(task: task),
          );
        },
      ),
    );
  }
}
