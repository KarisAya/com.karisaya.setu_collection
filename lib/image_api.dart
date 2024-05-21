import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "download.dart";
import "./settings.dart" show Settings;

Logger logger = Logger();

class ImageUrl {
  String? original;
  String? regular;
  final String url;
  ImageUrl(this.url, {this.original, this.regular});
  String get highestQuality {
    if (original != null) {
      return original!;
    } else if (regular != null) {
      return regular!;
    } else {
      return url;
    }
  }
}

abstract class CurrentStatus {
  abstract final String key;
  abstract final Map<String, dynamic> defaultSettings;

  List<ImageUrl> imageUrls = [];
  int currentIndex = 0;
  int maxIndex = 0;
  bool error = false;

  void indexTo(int index) {
    currentIndex = index;
    if (index > maxIndex) {
      maxIndex = index;
    }
  }

  void preUpdate() {
    imageUrls = imageUrls.sublist(0, maxIndex + 2);
  }

  late final Settings settings;

  void loadSettings(Settings value) {
    settings = value;
    if (!settings.apiSettings.containsKey(key)) {
      settings.apiSettings[key] = {...defaultSettings};
    }
    map = settings.apiSettings[key] as Map;
  }

  late Map map;
}

abstract class ImageAPI extends StatefulWidget {
  const ImageAPI({super.key});
  abstract final CurrentStatus status;
  // const ImageAPI(this.settings, {super.key});
  // final Settings settings;
}

abstract class ImageAPIState<T extends ImageAPI> extends State<T> {
  CarouselController carouselController = CarouselController();
  bool _isLoading = false;
  TextEditingController pageTEC = TextEditingController();

  void onPageChanged(int index) {
    setState(() {
      widget.status.indexTo(index);
      if (index == widget.status.imageUrls.length - 1 && !_isLoading) {
        getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (widget.status.imageUrls.length > widget.status.currentIndex) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          CarouselSlider(
            carouselController: carouselController,
            options: CarouselOptions(
              autoPlay: false,
              enlargeCenterPage: true,
              viewportFraction: 0.6,
              aspectRatio: 1.0,
              height: MediaQuery.of(context).size.width,
              initialPage: widget.status.currentIndex,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                onPageChanged(index);
              },
            ),
            items: widget.status.imageUrls.map((url) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onLongPress: () {
                      downloadManager.download(url.highestQuality);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text(
                              '图片 ${widget.status.currentIndex + 1} 已加入下载队列！')));
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          fullscreenDialog: true,
                          builder: (context) => ImagePreviewPage(api: this),
                        ),
                      );
                    },
                    child: Center(
                      child: CachedNetworkImage(
                        imageUrl: url.url,
                        placeholder: (context, url) =>
                            const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          GestureDetector(
            child: Text((widget.status.currentIndex + 1).toString(),
                style: const TextStyle(
                  color: Colors.grey, // 文本颜色
                  fontSize: 24,
                )),
            onLongPress: () async {
              String? result = await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return buildAlertDialog(
                      context,
                      pageTEC,
                      title: const Text("输入跳转的页面"),
                      hintText: "1-${widget.status.imageUrls.length}",
                    );
                  });
              if (result == null) return;
              int? numInt = int.tryParse(result);
              if (numInt == null) return;
              if (numInt < 0 || numInt > widget.status.imageUrls.length) return;
              setState(() {
                carouselController.animateToPage(numInt - 1);
              });
            },
          )
        ],
      );
    } else if (widget.status.error) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              '哎呀！页面崩溃了...',
              style: TextStyle(fontSize: 24, color: Colors.black),
            ),
            ElevatedButton(
              onPressed: () {
                getData();
                setState(() {
                  widget.status.error = false;
                });
              },
              child: const Text('点击重试'),
            ),
          ],
        ),
      );
    } else {
      if (!_isLoading) {
        getData();
      }
      return const Center(child: CircularProgressIndicator());
    }
  }

  int coldDown = 0;
  getData() async {
    _isLoading = true;
    if (coldDown > DateTime.now().millisecondsSinceEpoch) {
      throw StateError('请求速度过快');
    }
    coldDown = DateTime.now().millisecondsSinceEpoch + 1000;
    try {
      logger.i("从${widget.status.key}获取图片列表..");
      widget.status.imageUrls.addAll(await getImageUrls());
    } catch (e) {
      if (widget.status.imageUrls.isEmpty) {
        widget.status.error = true;
      }
      logger.e(e);
    }
    _isLoading = false;
    if (mounted) {
      setState(() {});
    }
  }

  getImageUrls();
}

class ImagePreviewPage extends StatelessWidget {
  final ImageAPIState api;

  const ImagePreviewPage({super.key, required this.api});

  @override
  Widget build(BuildContext context) {
    return PageView.builder(
      onPageChanged: (int index) {
        api.onPageChanged(index);
        api.carouselController.jumpToPage(index);
      },
      controller: PageController(initialPage: api.widget.status.currentIndex),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Center(
              child: CachedNetworkImage(
            imageUrl: api.widget.status.imageUrls[index].url,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )),
          onTap: () {
            Navigator.pop(context);
          },
          onLongPress: () {
            downloadManager
                .download(api.widget.status.imageUrls[index].highestQuality);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content:
                    Text('图片 ${api.widget.status.currentIndex + 1} 已加入下载队列')));
          },
        );
      },
    );
  }
}

AlertDialog buildAlertDialog(
  BuildContext context,
  TextEditingController textEditingController, {
  Widget? title,
  String hintText = '在此输入...',
}) =>
    AlertDialog(
      title: title,
      content: TextField(
        controller: textEditingController,
        decoration: InputDecoration(hintText: hintText),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('取消'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('确认'),
          onPressed: () {
            Navigator.of(context).pop(textEditingController.text);
          },
        ),
      ],
    );
