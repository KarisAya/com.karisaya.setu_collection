package com.karisaya.setu_collection

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        "com.karisaya.setu_collection/mediaAPI"
                )
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "sflutteravePicture" -> {
                            val file = call.argument<String>("file")
                            if (file != null) {
                                try {
                                    saveImageToPublicDir(file)
                                } catch (e: Exception) {
                                    result.error(
                                            "Error",
                                            "Failed to save image.",
                                            e.localizedMessage
                                    )
                                }
                                result.success("Image saved successfully.")
                            } else {
                                result.error("INVALID_ARGUMENT", "Missing file parameter", null)
                            }
                        }
                    }
                }
    }

    private fun saveImageToPublicDir(file: String) {
        println(file)
    }
}
