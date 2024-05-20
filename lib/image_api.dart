import 'package:flutter/material.dart';
import 'package:logger/logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "download.dart";

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

class CurrentStatus {
  CurrentStatus();
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
}

abstract class ImageAPIState<T extends StatefulWidget> extends State<T> {
  ImageAPIState({required this.api, required this.status});
  final String api;
  CurrentStatus status;
  CarouselController carouselController = CarouselController();
  bool _isLoading = false;
  TextEditingController pageTEC = TextEditingController();

  void onPageChanged(int index) {
    setState(() {
      status.indexTo(index);
      if (index == status.imageUrls.length - 1 && !_isLoading) {
        getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (status.imageUrls.length > status.currentIndex) {
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
              initialPage: status.currentIndex,
              enableInfiniteScroll: false,
              onPageChanged: (index, reason) {
                onPageChanged(index);
              },
            ),
            items: status.imageUrls.map((url) {
              return Builder(
                builder: (BuildContext context) {
                  return GestureDetector(
                    onLongPress: () {
                      downloadManager.download(url.highestQuality);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('图片 ${status.currentIndex + 1} 已加入下载队列！')));
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
            child: Text((status.currentIndex + 1).toString(),
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
                      hintText: "1-${status.imageUrls.length}",
                    );
                  });
              if (result == null) return;
              int? numInt = int.tryParse(result);
              if (numInt == null) return;
              if (numInt < 0 || numInt > status.imageUrls.length) return;
              setState(() {
                carouselController.animateToPage(numInt - 1);
              });
            },
          )
        ],
      );
    } else if (status.error) {
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
                  status.error = false;
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
      throw StateError('请求速度过快，请稍后再试');
    }
    coldDown = DateTime.now().millisecondsSinceEpoch + 1000;
    try {
      logger.i("从$api获取图片列表..");
      status.imageUrls.addAll(await getImageUrls());
    } catch (e) {
      if (status.imageUrls.isEmpty) {
        status.error = true;
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
      controller: PageController(initialPage: api.status.currentIndex),
      itemBuilder: (BuildContext context, int index) {
        return GestureDetector(
          child: Center(
              child: CachedNetworkImage(
            imageUrl: api.status.imageUrls[index].url,
            placeholder: (context, url) => const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          )),
          onTap: () {
            Navigator.pop(context);
          },
          onLongPress: () {
            downloadManager
                .download(api.status.imageUrls[index].highestQuality);
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                content: Text('图片 ${api.status.currentIndex + 1} 已加入下载队列！')));
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
