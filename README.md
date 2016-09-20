# HideNavTabBarDemo

This accompanies the blog post at http://ios.kevinlowens.com/hide-bars/.

Current as of Swift 3 Xcode 8.0.

See the post for more information.

### Demonstrates:
- User-initiated hiding and showing (and time-delay hiding) of a navigation bar and/or tab bar through the use of the `BarsViewController`.
- Protocol for modeling table view cells that have a title label, detail label, and switch  
- Protocol-based MVC model `BarsSettingsModel`

### Reusable Components:
- `SetingsModel`: Provides a model that represents configurable on/off behaviors, to include for each behavior its title, description, and enabled state as would be represented in a table veiw.
- `LabelDetailSwitchModelProtocol`: Types conforming to this protocol provide the essentials for populating, querying, and receiving notifications from a model that backs a table view cell with label text, detail text, and a switch control. 

### Organization:
- The `Main.storyboard` is composed of a tab bar controller with two tabs, each tab being a navigation controller-embedded scene.
- The first scene, of class `FirstViewController`, begins with a view that segues to the settings table view.
- The second scene, of class `SecondViewController`, begins and ends with an all-in-one view with the container-embedded settings table view.
- Both `FirstViewController` and `SecondViewController` are subclasses of the `BarsViewController`. 
- A class that inherits from `BarsViewController` inherits the ability to hide and show automatically or via user interaction one or both of either the navigation bar and tab bar.
