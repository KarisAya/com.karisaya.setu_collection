package com.karisaya.setu_collection

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        "com.karisaya.setu_collection/mediaAPI",
                )
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "savePicture" -> {
                            val file = call.argument<String>("file")
                            if (file != null) {
                                try {
                                    saveImageToPictures(file)
                                    result.success("Image saved successfully.")
                                } catch (e: Exception) {
                                    result.error(
                                            "Error",
                                            "Failed to save image.",
                                            e.localizedMessage
                                    )
                                }
                            } else {

                                result.error("INVALID_ARGUMENT", "Missing file parameter", null)
                            }
                        }
                    }
                }
    }

    private fun saveImageToPictures(file: String) {
        val imageFile = File(file)
        if (!imageFile.exists()) return
        val picturesDir =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
        val destinationFile = File(picturesDir, imageFile.name)
        imageFile.copyTo(destinationFile, overwrite = true)
        imageFile.delete()
    }
}
