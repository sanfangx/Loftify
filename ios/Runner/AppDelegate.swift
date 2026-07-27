import Flutter
import UIKit

@UIApplicationMain
@objc class AppDelegate: FlutterAppDelegate {
  var backgroundTask: UIBackgroundTaskIdentifier = .invalid

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func applicationDidEnterBackground(_ application: UIApplication) {
    // Request extra time from iOS to allow SQLite and Hive to finish pending writes and release file locks
    backgroundTask = application.beginBackgroundTask(withName: "SQLiteLockPreventer") {
      application.endBackgroundTask(self.backgroundTask)
      self.backgroundTask = .invalid
    }
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 5.0) {
      if self.backgroundTask != .invalid {
        application.endBackgroundTask(self.backgroundTask)
        self.backgroundTask = .invalid
      }
    }
    
    super.applicationDidEnterBackground(application)
  }
}
