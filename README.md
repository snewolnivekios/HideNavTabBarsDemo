# HideNavTabBarDemo

This accompanies the blog post at http://ios.kevinlowens.com/hide-bars/.

Current as of Swift 3 Xcode 8.1; supports iOS 9.3 and later.

### Demonstrates:
This project demonstrates hiding and showing (and time-delay hiding) of a navigation bar and/or tab bar and tab bar-"attached" view, with configurable behaviors controlling which bars hide, and whether they auto-hide and auto-show.

It also demonstrates using a generic plist-model-backed table view controller for managing switch-based on/off settings, which is in this case used to allow the user to tailor the hiding-bars behavior.

### How to Use:
Drop `HidingBars.swift` into your project and conform your `UITabViewController`-managed `UIViewController` to the `HidingBars` protocol, following the instructions given in the documentation for that protocol.

### Organization:
- The `Main.storyboard` is composed of a tab bar controller with three tabs, each tab being a navigation controller-embedded scene.
- The `FirstViewController` sublasses `BarsViewController` and presents a bars-hiding view that segues to a settings view.
- The `SecondViewController` sublasses `BarsViewController`  and presents an all-in-one bars-hiding view combined with the container-embedded settings view.
- The `ThirdViewController` is a bars-hiding view with no accomapnying settings view. __This controller demonstrates the lightest `BarsSettings` implementation you'd be most likely to use in your own project.__  
- The `BarsSettingsViewController` presents the `BarsSettingsModel` configuraton items that affect the hiding-bars behavior of its calling view controller.
