package com.karisaya.setu_collection

import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import android.webkit.MimeTypeMap
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        "com.karisaya.setu_collection/Media API"
                )
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "SavePicture" -> {
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

        // 获取外部存储的Pictures目录
        val picturesDirectory =
                Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)

        // 确保目录存在
        if (!picturesDirectory.exists()) {
            picturesDirectory.mkdirs()
        }

        // 创建目标文件
        val originalFile = File(file)
        val fileName = originalFile.name
        val targetFile = File(picturesDirectory, fileName)

        try {
            // 复制文件到目标位置
            originalFile.copyTo(targetFile, overwrite = true)

            // 如果需要更新媒体库，使用MediaStore API（针对Android Q及以上版本推荐）
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                // 获取文件MIME类型
                val mimeType =
                        MimeTypeMap.getSingleton()
                                .getExtensionFromMimeType(
                                        context.contentResolver.getType(Uri.fromFile(targetFile))
                                )
                                ?: "image/jpeg"
                val contentValues =
                        ContentValues().apply {
                            put(MediaStore.Images.Media.DISPLAY_NAME, fileName)
                            put(MediaStore.Images.Media.MIME_TYPE, mimeType)
                            put(
                                    MediaStore.Images.Media.RELATIVE_PATH,
                                    Environment.DIRECTORY_PICTURES
                            )
                        }

                // 插入到MediaStore，这会触发媒体扫描
                val resolver = this.contentResolver
                val uri =
                        resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)
                if (uri != null) {
                    resolver.openOutputStream(uri)?.use { outputStream ->
                        FileInputStream(targetFile).use { inputStream ->
                            inputStream.copyTo(outputStream)
                        }
                    }
                }
            } else {
                // 对于Android Q以下版本，使用传统方式通知媒体扫描
                context.sendBroadcast(
                        Intent(Intent.ACTION_MEDIA_SCANNER_SCAN_FILE, Uri.fromFile(targetFile))
                )
            }

            println("Image saved to Pictures directory successfully.")
        } catch (e: Exception) {
            println("Error saving image: ${e.message}")
        }
    }
}
