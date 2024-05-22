package com.karisaya.setu_collection

import android.Manifest
import android.content.ContentValues
import android.content.pm.PackageManager
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

//import okhttp3.OkHttpClient
//import okhttp3.Request
//
//
//val httpClient = OkHttpClient()

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "com.karisaya.setu_collection",
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "insertImage" -> {
                    val it = byteArrayOf(0, 0, 0, 0)
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) saveImage(it)
                    else saveImageOld(it)
                    result.success(null)
                }
            }
        }
    }


    private fun saveImage(bytes: ByteArray) {
        val resolver = this.contentResolver
        val time = System.currentTimeMillis()
        val contentValues = ContentValues().apply {
            put(MediaStore.Images.Media.DATE_TAKEN, time)
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            put(MediaStore.Images.Media.RELATIVE_PATH, "Pictures/setu_collection/${time}.png")
        }
        resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, contentValues)?.let { uri ->
            resolver.openOutputStream(uri)?.use {
                it.write(bytes)
            }
        }
    }

    private fun saveImageOld(bytes: ByteArray) {
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
            }) return
        val file = Environment.getExternalStoragePublicDirectory(
            Environment.DIRECTORY_PICTURES
        ).resolve("/setu_collection/${System.currentTimeMillis()}.png")
        file.writeBytes(bytes)
    }
}
