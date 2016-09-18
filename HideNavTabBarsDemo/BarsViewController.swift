//
//  BarsViewController.swift
//  BarsDemo
//
//  Copyright © 2016 Kevin L. Owens. All rights reserved.
//
//  BarsDemo is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  BarsDemo is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with BarsDemo.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

/// Subclasses of `BarsViewController` inherit the ability to hide and show automatically or via user interaction one or both of either the navigation bar and tab bar.
///
/// Which bars can be hidden is controlled by the `BarsSettingsModel` properties `hideNavBar` and `hideTabBar`. How the bars animate on segues is controlled by its `hideOnAppear`, `showOnAppear`, and `autoHideDelay` properties.
class BarsViewController: UIViewController {

  /// The keeper of the nav and tab bar hide/show settings.
  var model: BarsSettingsModel!

  /// True when the bars are currently hidden; false, otherwise.
  var barsHidden = false

  /// The means by which the bars are hidden after a delay.
  private var autoHideTimer: Timer?

  /// When true, the bars hide after the view appears.
  ///
  /// Used in conjunction with the `BarModel` property by the same name, this value enables user override of that the model's setting.
  ///
  /// If the user explicitly _shows_ the bars when hide-on-appear is enabled, this value is used by `toggleBars(sender:)` to temporarily turn off auto hiding until the user explicitly _hides_ the bars.
  private var hideOnAppear: Bool!


  /// Initializes the settings model with an id unique to `self`.
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    model = BarsSettingsModel(id: "\(self)")
  }


  //////
  // MARK: - View setup

  /// Establishes self as an observer for `LabelDetailSwitchModelProtocol` (`BarsSettingsModel`) switch value changes.
  override func viewDidLoad() {
    super.viewDidLoad()
    hideOnAppear = model.hideOnAppear
    model.add(observer: changedSetting(with:isOn:), forObject: self)
  }


  /// Displayes the navigation and tab bars in accordance with the `BarsSettingsModel` settings and installs tap gesture recognizer notifications to `toggleBars(sender:)`.
  override func viewWillAppear(_ animated: Bool) {

    if !model.hideTabBar {
      setTabBar(hidden: false, animated: false)
    }
    if !model.hideNavBar {
      setNavBar(hidden: false, animated: true)
    }
    setBars(hidden: model.showOnAppear ? false : barsHidden, animated: true)

    view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(toggleBars(sender:))))
  }


  /// Upon dismissal of view, terminates any pending auto-hide timers.
  override func viewWillDisappear(_ animated: Bool) {
    autoHideTimer?.invalidate()
  }


  /// Injects the current `BarsSettingsModel` into the destination `BarsSettingsViewController` and shows the tab bar for use by that view.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? BarsSettingsViewController {
      destination.model = model
    }
    setTabBar(hidden: false, animated: true)
  }


  //////
  // MARK: - Bar Management

  /// In response to a tap gesture, toggles the visibility of the navigation and tab bars in accordance with the `BarsSettingsModel` settings.
  /// - parameter sender: The tap gesture recognizer.
  func toggleBars(sender: UITapGestureRecognizer) {

    guard model.hideNavBar || model.hideTabBar else { return }

    // If hide-on-appear is enabled and the user has explicitly shown the bars, turn off auto-hiding until they explicitly hide the bars again.
    if model.hideOnAppear {
      hideOnAppear = !barsHidden
    }

    setBars(hidden: !barsHidden, animated: true)
  }


  /// Shows and hides the navigation and tab bars in accordance with the `BarsSettingsModel` settings.
  ///
  /// If hide-on-appear is enabled and the bars either are showing or are being shown (`hidden` is `false`), installs the timer to auto-hide after `autoHideDelay`.
  /// - parameter hidden: When `true`, the bars for which hiding is enabled are hidden; when `false`, hidden bars are un-hidden.
  /// - parameter animated: When `true`, the hide and show actions are animated; otherwise, they are not.
  func setBars(hidden: Bool, animated: Bool) {

    // Cancel any auto-hide
    autoHideTimer?.invalidate()

    // Initiate auto-hide
    if (!hidden || !barsHidden) && hideOnAppear {
      if #available(iOS 10.0, *) {
        autoHideTimer = Timer.scheduledTimer(withTimeInterval: model.autoHideDelay, repeats: false ) { _ in
          self.setBars(hidden: true, animated: true)
        }
      } else {
        // Fallback on earlier versions
        autoHideTimer = Timer.scheduledTimer(timeInterval: model.autoHideDelay, target: self, selector: #selector(BarsViewController.hideBars), userInfo: nil, repeats: false)
      }
    }

    // Hide/show bars
    barsHidden = hidden
    if model.hideNavBar {
      setNavBar(hidden: hidden, animated: animated)
    }
    if model.hideTabBar {
      setTabBar(hidden: hidden, animated: animated)
    }
  }


  /// As the target for the auto-hide timer, hides the bars.
  func hideBars() {
    // Required for iOS 9.x and earlier (timer accepts a closure in iOS 10).
    setBars(hidden: true, animated: true)
  }


  /// Shows and hides the navigation bar.
  /// - parameter hidden: When `true`, the bar is hidden; when `false`, it is shown.
  /// - parameter animated: When `true`, the hide and show actions are animated; when `false`, they are not.
  func setNavBar(hidden: Bool, animated: Bool) {
    navigationController?.setNavigationBarHidden(hidden, animated: true)
  }


  /// Shows and hides the tab bar.
  /// - parameter hidden: When `true`, the bar is hidden; when `false`, it is shown.
  /// - parameter animated: When `true`, the hide and show actions are animated; when `false`, they are not.
  func setTabBar(hidden: Bool, animated: Bool) {
    // Source: http://stackoverflow.com/a/27072876/4538429

    //* This cannot be called before viewDidLayoutSubviews(), because the frame is not set before this time

    guard let tabBarController = tabBarController else { return }

    // Bail if the current state matches the desired state
    let tabBarIsVisible = tabBarController.tabBar.frame.origin.y < self.view.frame.maxY
    if (tabBarIsVisible != hidden) { return }

    // Get a frame calculation ready
    let frame = tabBarController.tabBar.frame
    let height = frame.size.height
    let offsetY = (hidden ? height : -height)

    // Zero duration means no animation
    let duration: TimeInterval = (animated ? 0.25 : 0.0)

    //  Animate the tabBar
    UIView.animate(withDuration: duration) {
      tabBarController.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
      return
    }
  }


  /// As the target action for the `LabelDetailSwitchModelProtocol` (`BarsSettingsModel`) switch value changes, updates the temporary user-override `hideOnAppear` with that given by the setting.
  /// - parameter name: The identifier for the setting.
  /// - parameter isOn: Mirrors the changed `isOn` value of the corresponding `UISwitch`.
  func changedSetting(with name: String, isOn: Bool) {
    if name == "hideOnAppear" {
      hideOnAppear = isOn
    }
  }
}
