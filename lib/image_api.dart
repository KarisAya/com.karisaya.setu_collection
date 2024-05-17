import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:path_provider/path_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import "download.dart";

Logger logger = Logger();
Dio dio = Dio();

class CurrentStatus {
  CurrentStatus();
  List<String> imageUrls = [];
  int currentIndex = 0;
  bool error = false;
}

abstract class ImageAPIState<T extends StatefulWidget> extends State<T> {
  ImageAPIState({required this.api, required this.status});
  final String api;
  CurrentStatus status;
  bool _isLoading = false;

  void onPageChanged(int index) {
    setState(() {
      status.currentIndex = index;
      if (index == status.imageUrls.length - 1 && !_isLoading) {
        getData();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (status.error) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '哎呀！页面崩溃了...',
              style: TextStyle(fontSize: 24, color: Colors.white),
            ),
            SizedBox(height: 20),
            Text(
              '请稍后重试',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            SizedBox(height: 30),
          ],
        ),
      );
    } else if (status.imageUrls.length > status.currentIndex) {
      return Column(
        children: [
          CarouselSlider(
            options: CarouselOptions(
              autoPlay: false,
              enlargeCenterPage: true,
              aspectRatio: 1.0,
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
                      downloadFile(url);
                      ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content:
                              Text('已将图片${status.currentIndex + 1}添加到下载队列！')));
                    },
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ImagePreviewPage(api: this),
                        ),
                      );
                    },
                    child: Container(
                      width: MediaQuery.of(context).size.width,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 5.0,
                        vertical: 20,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8.0),
                        image: DecorationImage(
                          image: CachedNetworkImageProvider(url),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  );
                },
              );
            }).toList(),
          ),
          Text((status.currentIndex + 1).toString(),
              style: const TextStyle(
                color: Colors.grey, // 文本颜色
                fontSize: 24,
              )),
        ],
      );
    } else if (!_isLoading) {
      getData();
    }
    return const Center(child: CircularProgressIndicator());
  }

  downloadFile(String fileUrl) {
    download(fileUrl, "image.jpg");
    // var dir = await getExternalStorageDirectory();
    // if (dir == null) return;
    // String filePath = '${dir.path}/Pictures/setu collection/image.jpg';
    // await dio.download(fileUrl, filePath);
  }

  int coldDown = 0;
  getData() async {
    setState(() {
      _isLoading = true;
    });
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
    setState(() {
      _isLoading = false;
    });
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
      },
      controller: PageController(initialPage: api.status.currentIndex),
      itemBuilder: (BuildContext context, int index) {
        return Image(
            image: CachedNetworkImageProvider(api.status.imageUrls[index]));
      },
    );
  }
}
