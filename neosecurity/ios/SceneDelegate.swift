import Flutter
import UIKit

@objc class SceneDelegate: FlutterSceneDelegate {
  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard let flutterViewController = window?.rootViewController as? FlutterViewController else {
      return
    }

    let configChannel = FlutterMethodChannel(
      name: "com.neo.config/channel",
      binaryMessenger: flutterViewController.binaryMessenger
    )

    configChannel.setMethodCallHandler {
      [weak self] (call: FlutterMethodCall, result: FlutterResult) -> Void in
      switch call.method {
      case "getAppName":
        if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
          result(appName)
        } else {
          result("앱 이름 없음")
        }
      case "getGaetongCode":
        if let gaetongCode = Bundle.main.infoDictionary?["FLUTTER_GAETONG_CODE"] as? String {
          result(gaetongCode)
        } else {
          result("개통코드 없음")
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
