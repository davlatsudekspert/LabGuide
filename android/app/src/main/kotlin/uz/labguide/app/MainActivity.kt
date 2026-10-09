package uz.labguide.app

import android.os.Build
import android.speech.SpeechRecognizer
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // Leykoformula ovozli buyruqlari: faqat qurilmada (oflayn) tanish
        // mavjud bo'lsa yoqiladi — ovoz tizim xizmati serveriga ketmasin.
        // speech_to_text `onDevice: true` bilan Android 12+ da shu holatda
        // createOnDeviceSpeechRecognizer ishlatadi.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "uz.labguide.app/speech")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "onDeviceAvailable" -> result.success(
                        Build.VERSION.SDK_INT >= Build.VERSION_CODES.S &&
                            SpeechRecognizer.isOnDeviceRecognitionAvailable(this)
                    )
                    else -> result.notImplemented()
                }
            }
    }
}
