//
//  HidingBars.swift
//  HideNavTabBarsDemo
//
//  Copyright © 2016 Kevin L. Owens. All rights reserved.
//
//  HideNavTabBarsDemo is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  HideNavTabBarsDemo is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with HideNavTabBarsDemo.  If not, see <http://www.gnu.org/licenses/>.
//

import UIKit

// MARK: Protocol HidingBarsSettings

/// A type conforming to this protocol provides configurable items for the `HidingBars` protocol and a mechanism for maintaining state needed for its operation.
protocol HidingBarsSettings {

  // MARK: Configuration

  /// When `true`, the tab bar can be hidden.
  var hideTabBar: Bool { get }

  /// When `true`, the navigation bar can be hidden.
  var hideNavBar: Bool { get }

  /// When `true`, the bars set to hide do so automatically on view-will-appear after an `autoHideDelay`.
  var hideOnAppear: Bool { get }

  /// When `true`, the bars show on view-will-appear; otherwise, they remain in their last configuration.
  var showOnAppear: Bool { get }

  /// The delay before the bars are automatically hidden.
  var autoHideDelay: TimeInterval { get }

  /// The view animated with the tab bar. This view may be constrained either to the bottom layout guide or the bottom edge of the view.
  var tabBarAttachedView: UIView? { get set }


  // MARK: State

  /// `true` when the user has manually shown the bars after they were automatically hidden.
  var autoHideOverride: Bool { get set }

  /// `true` when the bars are currently hidden; `false`, otherwise.
  var barsHidden: Bool { get set }

  /// Hides the bars if not cancelled before the `autoHideDelay` expires.
  ///
  /// Auto-hide is cancelled each time the bars visibility state is toggled, and should also be cancelled by the implementing view controller in response to `viewWillDisappear(_:)`.
  var autoHideWorkItem: DispatchWorkItem? { get set }
}


/// Associates `HidingBars` configurations with `UIViewController` events. Call `updateBars(for:)` in the view controller method corresponding to each event.
enum HidingBarsEvent {

  /// To be called on `viewDidLoad(_:)`, "attaches" the given view (if provided) to the tab bar and installs the gesture recognizer (if provided) for toggling the bars visibility.
  ///
  /// The attachedView needs to have its bottom edge constrained either to the view or the bottom layout guide.
  case viewDidLoad(attachedView: UIView?, recognizer: UIGestureRecognizer?)

  /// To be called on `viewWillAppear(_:)`, resets any bars auto-hide override the user set by explicitly showing the bars, and shows the bars if `showOnAppear` is enabled; otherwise, shows the bars according to their last `barsHidden` state.
  case viewWillAppear

  /// To be called on `viewWillTransition(to:with:)`, makes the bars visible when the device rotates, auto-hiding in accordance with the `hideOnAppear` setting.
  case viewWillTransition

  /// To be called on `viewWillDisappear(_:)`, cancels any pending auto-hide.
  case viewWillDisappear
}


// MARK: - Protocol HidingBars

/// A `UIViewController` conforming to this protocol gains the ability to hide and show either or both the navigation and tab bars.
///
/// The behavior is configured by an instance of `HidingBarsSettings`.
///
/// To utilize this functionality, a conforming view controller must:
/// 1. Initialize a `HidingBarsSettings` property.
/// 1. In `viewDidLoad(_:)`, optionally call `updateBars(for: .viewDidLoad(attachedView:recognizer:))`.
/// 1. In `viewWillAppear(_:)`, call `updateBars(for: .viewWillAppear)`.
/// 1. In `viewWillTransition(to:with:)`, call `updateBars(for: .viewWillTransition)`.
/// 1. In `viewWillDisappear(_:)`, call `updateBars(for: .viewWillDisappear)`.
protocol HidingBars: class {

  /// Configures bars behaviors.
  var barsSettings: HidingBarsSettings { get set }
}


extension HidingBars where Self: UIViewController {

  /// Performs bars configurations for each `HidingBarsEvent`. Call this method in the corresponding view controller method.
  func updateBars(for event: HidingBarsEvent) {
    switch event {
    case let .viewDidLoad(attachedView, recognizer):
      if let attachedView = attachedView {
        barsSettings.tabBarAttachedView = attachedView
      }
      if let recognizer = recognizer {
        view.addGestureRecognizer(recognizer)
      }
    case .viewWillAppear:
      barsSettings.autoHideOverride = false
      setBars(hidden: barsSettings.showOnAppear ? false : barsSettings.barsHidden, animated: true)
    case .viewWillTransition:
      let myTabBarController: UIViewController = self.parent is UINavigationController ? self.parent! : self // tab bar view controller may be a UIViewController or UINavigationController
      if tabBarController?.selectedViewController == myTabBarController {
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) { // since this is a will-transition, need to allow time for the view frames to update
          self.setBars(hidden: self.barsSettings.showOnAppear ? false : self.barsSettings.barsHidden, animated: true)
        }
      }
    case .viewWillDisappear:
      barsSettings.autoHideWorkItem?.cancel()
    }
  }


  /// Toggles the visibility of the navigation and tab bars in accordance with `barsSettings`.
  func toggleBars() {
    barsSettings.autoHideOverride = barsSettings.barsHidden
    setBars(hidden: !barsSettings.barsHidden, animated: true)
  }


  /// Shows and hides the navigation and tab bars in accordance with `barsSettings`.
  ///
  /// If hide-on-appear is enabled and the bars either are showing or are being shown (`hidden` is `false`), installs the timer to auto-hide after `autoHideDelay`.
  ///
  /// - parameter hidden: When `true`, the bars for which hiding is enabled are hidden; when `false`, hidden bars are un-hidden.
  /// - parameter animated: When `true`, the hide and show actions are animated; otherwise, they are not.
  func setBars(hidden: Bool, animated: Bool) {

    // Cancel any auto-hide
    barsSettings.autoHideWorkItem?.cancel()

    // Initiate auto-hide
    if barsSettings.hideOnAppear && !barsSettings.autoHideOverride && (!hidden || !barsSettings.barsHidden) {
      barsSettings.autoHideWorkItem = DispatchWorkItem {
        self.setBars(hidden: true, animated: true)
      }
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + barsSettings.autoHideDelay, execute: barsSettings.autoHideWorkItem!)
    }

    // Hide/show bars
    barsSettings.barsHidden = hidden
    if barsSettings.hideNavBar {
      setNavBar(hidden: hidden, animated: animated)
    }
    if barsSettings.hideTabBar {
      setTabBar(hidden: hidden, animated: animated)
    }
  }


  /// Shows and hides the navigation bar.
  ///
  /// - parameter hidden: When `true`, the bar is hidden; when `false`, it is shown.
  /// - parameter animated: When `true`, the hide and show actions are animated; when `false`, they are not.
  func setNavBar(hidden: Bool, animated: Bool) {
    navigationController?.setNavigationBarHidden(hidden, animated: true)
  }


  /// Shows and hides the tab bar.
  ///
  /// - parameter hidden: When `true`, the bar is hidden; when `false`, it is shown.
  /// - parameter animated: When `true`, the hide and show actions are animated; when `false`, they are not.
  func setTabBar(hidden: Bool, animated: Bool) {
    // Inspiration: http://stackoverflow.com/a/27072876/4538429

    guard let tabBarController = tabBarController else { return }

    // Get a frame calculation ready
    let tabBarFrame = tabBarController.tabBar.frame
    let height = tabBarFrame.size.height
    let offsetY = (hidden ? height : -height)

    let animationDuration: TimeInterval = (animated ? 0.25 : 0.0)

    // Position the tabbar-attached view
    if let attachedView = barsSettings.tabBarAttachedView {
      let newFrame = attachedView.frame.offsetBy(dx: 0, dy: hidden ? offsetY : 0)
      UIView.animate(withDuration: animationDuration) {
        attachedView.frame = newFrame
      }
    }

    // Reposition the tabBar if the current state does not match the to state
    let tabBarIsVisible = tabBarController.tabBar.frame.origin.y < self.view.frame.maxY
    if tabBarIsVisible == hidden {
      let newFrame = tabBarFrame.offsetBy(dx: 0, dy: offsetY)
      UIView.animate(withDuration: animationDuration) {
        tabBarController.tabBar.frame = newFrame
      }
    }
  }
}
