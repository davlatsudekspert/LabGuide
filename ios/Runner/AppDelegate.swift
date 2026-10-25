import DeviceCheck
import Flutter
import Security
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Kunlik eslatma (flutter_local_notifications): ilova ochiq bo'lganda
    // ham ko'rsatish va bosilganda ilovaga xabar berish uchun.
    UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
    if let registrar = engineBridge.pluginRegistry.registrar(forPlugin: "LabGuideAttestation") {
      AttestationChannel.register(messenger: registrar.messenger())
    }
  }
}

/// 7 kunlik sinov uchun qurilma attestatsiyasi (D-77 addendum): Apple
/// DeviceCheck (`DCDevice.generateToken`). Server (cloudflare/src/attestation.ts)
/// tokenni Apple'ga yuborib ikki bitni o'qiydi/yozadi (bit0 = sinov ishlatilgan).
/// `deviceId` — Keychain'dagi tasodifiy UUID (shu qurilmada; ilova qayta
/// o'rnatilganda odatda saqlanadi — kafolat emas). App Attest ishlatilmaydi.
/// Bu kod shu muhitda KOMPILYATSIYA QILINMAGAN va qurilmada sinalmagan (NOT RUN).
enum AttestationChannel {
  static func register(messenger: FlutterBinaryMessenger) {
    let channel = FlutterMethodChannel(name: "uz.labguide.app/attestation", binaryMessenger: messenger)
    channel.setMethodCallHandler { call, result in
      switch call.method {
      case "isSupported":
        result(DCDevice.current.isSupported)
      case "deviceId":
        result(KeychainDeviceId.value())
      case "attest":
        guard DCDevice.current.isSupported else {
          result(FlutterError(code: "devicecheck_unsupported", message: nil, details: nil))
          return
        }
        DCDevice.current.generateToken { data, error in
          DispatchQueue.main.async {
            if let data = data {
              result(data.base64EncodedString())
            } else {
              let kind = error.map { String(describing: type(of: $0)) } ?? "unknown"
              result(FlutterError(code: "devicecheck_failed", message: kind, details: nil))
            }
          }
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}

/// Keychain'da saqlanadigan tasodifiy qurilma belgisi (ThisDeviceOnly —
/// zaxira nusxadan boshqa qurilmaga o'tmaydi).
enum KeychainDeviceId {
  private static let service = "uz.labguide.attestation"
  private static let account = "device-id"

  static func value() -> String? {
    if let existing = read() { return existing }
    let id = UUID().uuidString.lowercased()
    let add: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly,
      kSecValueData as String: Data(id.utf8),
    ]
    let status = SecItemAdd(add as CFDictionary, nil)
    return status == errSecSuccess || status == errSecDuplicateItem ? (read() ?? id) : nil
  }

  private static func read() -> String? {
    let query: [String: Any] = [
      kSecClass as String: kSecClassGenericPassword,
      kSecAttrService as String: service,
      kSecAttrAccount as String: account,
      kSecReturnData as String: true,
      kSecMatchLimit as String: kSecMatchLimitOne,
    ]
    var item: CFTypeRef?
    guard SecItemCopyMatching(query as CFDictionary, &item) == errSecSuccess,
          let data = item as? Data else { return nil }
    return String(data: data, encoding: .utf8)
  }
}
