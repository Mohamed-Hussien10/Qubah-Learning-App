import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate, FlutterStreamHandler {
  private let securityChannelName = "com.qubah.learning/security"
  private let securityEventsChannelName = "com.qubah.learning/security_events"

  private var eventSink: FlutterEventSink?
  private var isProtectionEnabled = false
  private var privacyBlurView: UIVisualEffectView?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    let controller: FlutterViewController = window?.rootViewController as! FlutterViewController

    // Setup MethodChannel for control
    let securityChannel = FlutterMethodChannel(
      name: securityChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    securityChannel.setMethodCallHandler { [weak self] (call, result) in
      guard let self = self else { return }
      switch call.method {
      case "enableProtection":
        self.isProtectionEnabled = true
        self.checkAndNotifyCaptureState()
        result(true)
      case "disableProtection":
        self.isProtectionEnabled = false
        result(true)
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // Setup EventChannel for real-time capture events
    let eventChannel = FlutterEventChannel(
      name: securityEventsChannelName,
      binaryMessenger: controller.binaryMessenger
    )
    eventChannel.setStreamHandler(self)

    // Register observers for screen capture and screenshots
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureStatusChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userDidTakeScreenshot),
      name: UIApplication.userDidTakeScreenshotNotification,
      object: nil
    )

    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }

  // MARK: - FlutterStreamHandler
  public func onListen(withArguments arguments: Any?, eventSink events: @escaping FlutterEventSink) -> FlutterError? {
    self.eventSink = events
    // Send immediate initial status
    let isCaptured = UIScreen.main.isCaptured
    events(isCaptured)
    return nil
  }

  public func onCancel(withArguments arguments: Any?) -> FlutterError? {
    self.eventSink = nil
    return nil
  }

  // MARK: - Notification Handlers
  @objc private func screenCaptureStatusChanged() {
    checkAndNotifyCaptureState()
  }

  private func checkAndNotifyCaptureState() {
    let isCaptured = UIScreen.main.isCaptured
    eventSink?(isCaptured)
  }

  @objc private func userDidTakeScreenshot() {
    // Screenshot notification happens post-capture; log or report if needed
    print("[SECURITY] User took a screenshot on iOS.")
  }

  // MARK: - App Switcher Privacy Blur
  override func applicationWillResignActive(_ application: UIApplication) {
    super.applicationWillResignActive(application)
    if isProtectionEnabled {
      showPrivacyBlur()
    }
  }

  override func applicationDidBecomeActive(_ application: UIApplication) {
    super.applicationDidBecomeActive(application)
    hidePrivacyBlur()
    checkAndNotifyCaptureState()
  }

  private func showPrivacyBlur() {
    guard privacyBlurView == nil, let window = self.window else { return }
    let blurEffect = UIBlurEffect(style: .dark)
    let blurView = UIVisualEffectView(effect: blurEffect)
    blurView.frame = window.bounds
    blurView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
    blurView.tag = 998877
    window.addSubview(blurView)
    self.privacyBlurView = blurView
  }

  private func hidePrivacyBlur() {
    privacyBlurView?.removeFromSuperview()
    privacyBlurView = nil
  }
}
