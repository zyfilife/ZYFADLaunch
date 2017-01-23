# MYADLuanchView
启动广告页

## How to use it
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

self.window = UIWindow(frame: UIScreen.main.bounds)
self.window?.backgroundColor = .white

let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
self.window?.rootViewController = viewController
self.window?.makeKeyAndVisible()

let _ = MFAdLuanchView(type: MFAdLuanchCoolDownType.progress, isFirstLaunch: true, frame: UIScreen.main.bounds) {
print("广告页显示结束")
}
return true
}
