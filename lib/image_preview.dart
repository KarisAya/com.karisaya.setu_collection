import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:logger/logger.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:path_provider/path_provider.dart';
import "download.dart";

Logger logger = Logger();
Dio dio = Dio();

class CurrentStatus {
  CurrentStatus();
  List<String> imageUrls = [];
  int currentIndex = 0;
}

abstract class ImageAPIState<T extends StatefulWidget> extends State<T> {
  ImageAPIState({required this.api, required this.status});
  final String api;
  CurrentStatus status;
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    if (status.imageUrls.length > status.currentIndex) {
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
                setState(() {
                  status.currentIndex = index;
                  if (index == status.imageUrls.length - 1 && !_isLoading) {
                    getData();
                  }
                });
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
                          builder: (context) => ImagePreviewPage(
                            imageUrls: status.imageUrls,
                            initialIndex: status.currentIndex,
                          ),
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
                          image: NetworkImage(url),
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

  getData() async {
    setState(() {
      _isLoading = true;
    });
    try {
      logger.i("从$api获取图片列表..");
      status.imageUrls.addAll(await getImageUrls());

      // var resp = await dio.get("https://image.anosu.top/pixiv/json?num=30");
      // imageUrls.addAll(resp.data.map((item) => item["url"]));
    } catch (e) {
      logger.w(e);
    }
    setState(() {
      _isLoading = false;
    });
  }

  getImageUrls();
}

class ImagePreviewPage extends StatelessWidget {
  final List<String> imageUrls;
  final int initialIndex;

  const ImagePreviewPage(
      {super.key, required this.imageUrls, required this.initialIndex});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Preview'),
      ),
      body: PageView.builder(
        itemCount: imageUrls.length,
        controller: PageController(initialPage: initialIndex),
        itemBuilder: (BuildContext context, int index) {
          return Center(
            child: Image.network(imageUrls[index]),
          );
        },
      ),
    );
  }
}
