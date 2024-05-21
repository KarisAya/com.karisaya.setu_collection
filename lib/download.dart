import 'package:logger/logger.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

Logger logger = Logger();

MethodChannel channel = const MethodChannel(
  'com.karisaya.setu_collection/publicDirectory',
);

class DownloadManager {
  List<DownloadTask> tasks = [];
  void download(String url) {
    tasks.add(DownloadTask(url));
  }
}

DownloadManager downloadManager = DownloadManager();

typedef ProgressCallback = void Function(int current, int total);

class DownloadTask {
  DownloadTask(this.url, {this.title = "未定义图片"}) {
    status = 1;
    channel.invokeMethod('insertImage', url).then((file) => (status = 2));
  }

  /// 0 未开始
  ///
  /// 1 下载中
  ///
  /// 2 已完成
  int status = 0;
  final String url;
  final String title;
}

class DownloadProgress extends StatefulWidget {
  const DownloadProgress({super.key, required this.task});
  final DownloadTask task;

  @override
  State<DownloadProgress> createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<DownloadProgress> {
  @override
  Widget build(BuildContext context) {
    Widget subtitle;
    switch (widget.task.status) {
      case (0):
        subtitle = const Text('未开始');
      case (1):
        subtitle = const Text('下载中');
      case (2):
        subtitle = const Text('下载完成');
      default:
        subtitle = const Text('未知状态');
    }
    return ListTile(
      title: Text(widget.task.title),
      subtitle: subtitle,
    );
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
        backgroundColor: Theme.of(context).colorScheme.primary,
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
