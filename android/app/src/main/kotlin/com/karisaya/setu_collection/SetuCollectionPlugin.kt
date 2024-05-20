import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class SetuCollectionPlugin : MethodCallHandler {
    companion object {
        private const val CHANNEL = "com.karisaya.setu_collection/get_public_dir"

        fun registerWith(flutterEngine: FlutterEngine) {
            val channel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            channel.setMethodCallHandler(SetuCollectionPlugin())
        }
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result) {
        if (call.method == "getPicturesPath") {
            val context = call.arguments as Context
            val path = getPublicPicturesPath(context)
            result.success(path)
        } else {
            result.notImplemented()
        }
    }

    private fun getPublicPicturesPath(context: Context): String {
        val downloadsDir = context.getExternalFilesDir(Environment.DIRECTORY_PICTURES)?.absolutePath
        return downloadsDir
                ?: Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                        .path
    }
}
