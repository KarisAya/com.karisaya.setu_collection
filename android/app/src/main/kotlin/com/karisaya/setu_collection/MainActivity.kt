package com.karisaya.setu_collection

import android.content.ContentValues
import android.provider.MediaStore
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import okhttp3.OkHttpClient

val httpClient = OkHttpClient()

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
                        flutterEngine.dartExecutor.binaryMessenger,
                        "com.karisaya.setu_collection",
                )
                .setMethodCallHandler { call, result ->
                    when (call.method) {
                        "insertImage" -> {
                            val resolver = this.contentResolver
                            val contentValues =
                                    ContentValues().apply {
                                        put(
                                                MediaStore.Images.Media.DATE_TAKEN,
                                                System.currentTimeMillis(),
                                        )
                                        put(
                                                MediaStore.Images.Media.MIME_TYPE,
                                                "image/png",
                                        )
                                        put(
                                                MediaStore.Images.Media.RELATIVE_PATH,
                                                "Pictures/setu_collection",
                                        )
                                    }
                            val uri =
                                    resolver.insert(
                                            MediaStore.Images.Media.EXTERNAL_CONTENT_URI,
                                            contentValues
                                    )
                            uri?.let {
                                resolver.openOutputStream(it)?.use { outputStream ->
                                    outputStream.write(call.arguments())
                                    result.success(null)
                                    return@setMethodCallHandler
                                }
                            }
                            result.error("MediaStoreError", "some wrong happened", null)
                        }
                    }
                }
    }
}
