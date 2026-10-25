package uz.labguide.app

import android.annotation.SuppressLint
import android.content.pm.PackageManager
import android.os.Build
import android.provider.Settings
import android.speech.SpeechRecognizer
import com.google.android.play.core.integrity.IntegrityManagerFactory
import com.google.android.play.core.integrity.IntegrityTokenRequest
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

        // 7 kunlik sinov uchun qurilma attestatsiyasi (D-77 addendum):
        // Google Play Integrity (classic so'rov). Nonce'ni Dart tomoni
        // hisoblaydi: base64url(SHA-256("labguide-trial-v1|<server nonce>|<ANDROID_ID>")),
        // server (cloudflare/src/attestation.ts) xuddi shunday tekshiradi.
        // Qurilmada SINALMAGAN (NOT VERIFIED).
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "uz.labguide.app/attestation")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    // Google Play xizmatlari bor qurilma (Huawei/AOSP — yo'q → sinov tugmasi yo'q).
                    "isSupported" -> result.success(hasPlayServices())
                    // ANDROID_ID: Android 8+ da ilova imzo kaliti + foydalanuvchi +
                    // qurilma bo'yicha; qayta o'rnatishda o'zgarmaydi, factory
                    // reset va boshqa profilda o'zgaradi. Server faqat HMAC saqlaydi.
                    "deviceId" -> result.success(androidId())
                    "attest" -> {
                        val nonce = call.argument<String>("nonce")
                        if (nonce.isNullOrEmpty()) {
                            result.error("bad_args", "nonce", null)
                            return@setMethodCallHandler
                        }
                        val project = call.argument<Number>("cloudProjectNumber")?.toLong()
                        val builder = IntegrityTokenRequest.builder().setNonce(nonce)
                        if (project != null) builder.setCloudProjectNumber(project)
                        IntegrityManagerFactory.create(applicationContext)
                            .requestIntegrityToken(builder.build())
                            .addOnSuccessListener { response -> result.success(response.token()) }
                            .addOnFailureListener { e ->
                                // Tafsilot (xato turi) — faqat diagnostika; token yo'q.
                                result.error("integrity_failed", e.javaClass.simpleName, null)
                            }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun hasPlayServices(): Boolean =
        try {
            packageManager.getPackageInfo("com.google.android.gms", 0)
            true
        } catch (e: PackageManager.NameNotFoundException) {
            false
        }

    @SuppressLint("HardwareIds")
    private fun androidId(): String? =
        Settings.Secure.getString(contentResolver, Settings.Secure.ANDROID_ID)
}
