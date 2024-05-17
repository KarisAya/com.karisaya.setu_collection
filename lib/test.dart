import 'package:flutter/material.dart';

class MyHomePage2 extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage2>
    with TickerProviderStateMixin {
  late AnimationController _controller;
  bool showShareSheet = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showShareSheet() async {
    if (!showShareSheet) {
      showShareSheet = true;
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Swipe Up for Share')),
      body: GestureDetector(
        onVerticalDragEnd: (details) {
          _showShareSheet();
        },
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                children: [
                  // 你的图片或者其他内容
                  Text('Your Content Here'),
                ],
              ),
            ),
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return SlideTransition(
                  position: Tween<Offset>(
                    begin: Offset(0.0, 1.0),
                    end: Offset(0.0, 0.0),
                  ).animate(_controller),
                  child: showShareSheet
                      ? Container(
                          height: 200,
                          color: Colors.white,
                          child: Center(
                            child: Text('Sharing...',
                                style: TextStyle(fontSize: 24)),
                          ),
                        )
                      : Container(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
