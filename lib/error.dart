import 'package:flutter/material.dart';

class CrashPage extends StatelessWidget {
  const CrashPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.red,
      body: Center(
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
            ElevatedButton(
              onPressed: () {
                // 在这里添加实际的重试逻辑，例如导航回首页或其他操作
                Navigator.popAndPushNamed(context, '/home'); // 假设'/home'是你的首页路由
              },
              child: Text('重试'),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.red,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
