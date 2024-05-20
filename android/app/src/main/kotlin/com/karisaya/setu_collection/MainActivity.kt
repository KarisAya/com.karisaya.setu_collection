package com.karisaya.setu_collection

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        "com.karisaya.setu_collection/get_public_dir"
                )
                .setMethodCallHandler { call, result ->
                    if (call.method == "getPicturesPath") {
                        result.success("Hello Kotlin")
                    }
                }
    }
}
