package com.karisaya.setu_collection

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.media.MediaScannerConnection
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import okhttp3.*
import okio.IOException

val httpClient = OkHttpClient()

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.karisaya.setu_collection",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "insertImage" -> {
                    val request = Request.Builder().url(call.arguments as String).build()
                    httpClient.newCall(request).enqueue(object : Callback {
                        override fun onFailure(call: Call, e: IOException) {
                            result.error(
                                "NetworkError", "Failed to fetch image", e
                            )
                        }

                        override fun onResponse(
                            call: Call, response: Response
                        ) {
                            if (response.isSuccessful && response.body?.bytes()?.let {
                                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) saveImage(it)
                                    else saveImageOld(it)
                                } == true) result.success(null)
                            else result.error(
                                "NetworkError", "Failed to fetch image", null
                            )
                        }
                    })
                }
            }
        }
    }

    private fun saveImage(bytes: ByteArray): Boolean {
        val resolver = this.contentResolver
        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DATE_TAKEN, System.currentTimeMillis())
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/setu_collection/")
        }
        resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)?.let { uri ->
            resolver.openOutputStream(uri)?.use {
                it.write(bytes)
                return true
            }
        }
        return false
    }

    private fun saveImageOld(bytes: ByteArray): Boolean {
        val requiredPermissions = arrayOf(
            Manifest.permission.READ_EXTERNAL_STORAGE, Manifest.permission.WRITE_EXTERNAL_STORAGE
        )

        fun checkAndRequestPermissions() {
            val missingPermissions = requiredPermissions.filter {
                ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
            }
            if (missingPermissions.isEmpty()) return
            ActivityCompat.requestPermissions(this, missingPermissions.toTypedArray(), 1001)
        }
        checkAndRequestPermissions()
        if (requiredPermissions.any {
                ContextCompat.checkSelfPermission(this, it) != PackageManager.PERMISSION_GRANTED
            }) return false
        val file =
            Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES).resolve("setu_collection")
                .apply { mkdirs() }.resolve("${System.currentTimeMillis()}.png")
        file.writeBytes(bytes)
        MediaScannerConnection.scanFile(
            this, arrayOf(file.absolutePath), arrayOf("image/png"), null
        )
        return true
    }
}
