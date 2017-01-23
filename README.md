# MYADLuanchView
启动广告页

### Usage
```swift
func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    self.window = UIWindow(frame: UIScreen.main.bounds)
    self.window?.backgroundColor = .white
    let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as! ViewController
    self.window?.rootViewController = viewController
    self.window?.makeKeyAndVisible()
    //isFirstLaunch: 区分首次启动和从后台启动两种环境下显示广告页
    let adLaunchView = MYADLaunchView(coolDownType: .progress, isFirstLaunch: true, frame: UIScreen.main.bounds) {
        print("广告页显示结束")
    }
    //optional, default 0
    adLaunchView.bottomDistance = 200
    return true
}
```
