# HideNavTabBarDemo

This accompanies the blog post at http://ios.kevinlowens.com/hide-bars/.

Current as of Swift 3 Xcode 8.1; supports iOS 9.3 and 10.1.

### Demonstrates:
This project demonstrates:
- Hiding and showing of a tab bar, tab bar-"attached" view, and navigation bar, with configurable behaviors.
- Adding `NotificationCenter` notifications for `UIViewController` view event methods using Objective-C-based _method swizzling_.
- Extending `UIGestureRecognizer` to accept Swift closures as actions using Objective-C-based _property swizzling_.
- Using a _generic plist-model-backed table view controller_ for managing switch-based on/off settings, which is in this case is used to allow the user to tailor the hiding-bars behavior.

### How to Use:
Drop `HidingBars.swift`, `HidingBarsViewController.swift`, and `HidingBarsGestureRecognizer.swift` into your project and conform your `UITabViewController`-managed `UIViewController`-based controller to the `HidingBars` protocol, following the instructions given in the documentation for that protocol.

### Organization:
- The `Main.storyboard` composes a tab bar controller with three tabs, each tab being a navigation controller-embedded scene.
- The `FirstViewController` sublasses `BarsViewController` and presents a bars-hiding view that segues to a settings view.
- The `SecondViewController` sublasses `BarsViewController`  and presents an all-in-one bars-hiding view combined with the container-embedded settings view.
- The `ThirdViewController` is a bars-hiding view with _no accomapnying settings view_. __This controller demonstrates the lightest `BarsSettings` implementation you'd be most likely to use in your own project.__  
- The `BarsSettingsViewController` presents the `BarsSettingsModel` configuraton items that affect the hiding-bars behavior of its calling view controller.
- `HidingBars.swift` defines the `HidingBars UIViewController` protocol extension and supporting constructs.
- `HidingBarsViewController.swift` defines a `UIViewController` extension to swizzle view event methods (`viewDidLoad`, `viewWillAppear`, etc.) so that they post `NotificationCenter` notifications. Note, this extension is not specific to `HidingBars`, so could be used in any context. 
- `HidingBarsGestureRecognizer.swift` extends `UIGestureRecgnizer` to support closure-based actions (in addition to the standard `Selector`-based actions). Note, this extension is not specific to `HidingBars`, so could be used in any context.
