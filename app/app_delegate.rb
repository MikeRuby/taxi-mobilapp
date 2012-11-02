class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.makeKeyAndVisible
    location_controller = LocationController.alloc.init
    navigation_controller = UINavigationController.alloc.initWithRootViewController location_controller
    @window.rootViewController = navigation_controller
    true
  end
end
