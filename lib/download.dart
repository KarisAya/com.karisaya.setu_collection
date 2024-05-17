import 'dart:async';
import 'package:flutter/material.dart';

class DownloadTask {
  DownloadTask({required this.url, required this.name});
  double _progress = 0.0;
  int status = 0; // 0 未开始，1 正在下载， 2 已完成 3 暂停
  Timer? timer;

  final String name;
  final String url;

  void start() {
    status = 1;
    timer = Timer.periodic(const Duration(milliseconds: 100), (timer) {
      _progress += 1;
      if (_progress >= 100) {
        timer.cancel();
        status = 2;
      }
    });
  }

  void stop() {
    status = 3;
    timer?.cancel();
  }

  void cancel() {
    status = status == 2 ? 2 : 0;
    timer?.cancel();
  }
}

List<DownloadTask> _tasks = [];

void download(String url, String name) {
  var task = DownloadTask(url: url, name: name);
  _tasks.add(task);
  task.start();
}

class DownloadProgress extends StatefulWidget {
  const DownloadProgress({super.key, required this.task});
  final DownloadTask task;

  @override
  State<DownloadProgress> createState() => _DownloadProgressState();
}

class _DownloadProgressState extends State<DownloadProgress> {
  double progress = 0.0;
  Timer? timer;

  void listenProgress() {
    if (timer?.isActive == true) {
      return;
    }
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (widget.task.status != 1) {
        timer.cancel();
        return;
      }
      setState(() {
        progress = widget.task._progress;
      });
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
          listenProgress();
          icon = const Icon(Icons.pause);
          subtitle = LinearProgressIndicator(value: progress / 100);
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
    timer?.cancel();
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
                  _tasks.removeWhere(
                      (task) => task.status == 0 || task.status == 2);
                });
              },
              icon: const Text("清空列表"))
        ],
      ),
      body: ListView.builder(
        itemCount: _tasks.length,
        itemBuilder: (BuildContext context, int index) {
          final task = _tasks[index];
          return Dismissible(
            key: ValueKey(task),
            direction: DismissDirection.startToEnd,
            onDismissed: (direction) {
              task.cancel();
              _tasks.removeWhere((task) => task.status == 0);
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
