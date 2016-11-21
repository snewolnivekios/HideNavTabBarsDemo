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
  ///
  /// `toSize` is that given in the `UIViewController.viewWillTransition(to:with:)` notification.
  case viewWillTransition(toSize: CGSize)

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
/// 1. If using a container view for the tab-bar-attached view, set `HidingBarsAttachedView` as its class so it doesn't capture touch events.
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
      setBars(hidden: barsSettings.showOnAppear ? false : barsSettings.barsHidden, animated: false)

    case .viewWillTransition(let toSize):
      guard view.frame.size != toSize else { return } // Skip if 180° rotation
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

    // Hide/show bars
    barsSettings.barsHidden = hidden
    if barsSettings.hideNavBar {
      setNavBar(hidden: hidden, animated: animated)
    }
    if barsSettings.hideTabBar {
      setTabBar(hidden: hidden, animated: animated)
    }

    // If bars are showing, initiate auto-hide if feature is enabled and not overriden by user explicilty showing them
    if !hidden && barsSettings.hideOnAppear && !barsSettings.autoHideOverride {
      barsSettings.autoHideWorkItem = DispatchWorkItem {
        self.setBars(hidden: true, animated: true)
      }
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + barsSettings.autoHideDelay, execute: barsSettings.autoHideWorkItem!)
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
    let tabBarIsVisible = tabBarFrame.origin.y < self.view.frame.maxY

    // Position the tabbar-attached view
    if let attachedView = barsSettings.tabBarAttachedView {
      // If showing tab bar, don't account for tab bar movement if it's already visible or if nav bar was also hidden. In the latter case, the downward movement of the main view in response to the appearing nav bar results has a -offsetY effect.
      let offsetY = !hidden && (tabBarIsVisible || barsSettings.hideNavBar) ? 0 : offsetY
      let attachedViewFrame = attachedView.frame.offsetBy(dx: 0, dy: offsetY)
      UIView.animate(withDuration: animationDuration) {
        attachedView.frame = attachedViewFrame
      }
    }

    // Reposition the tabBar if the current state does not match the to state
    if tabBarIsVisible == hidden {
      let newFrame = tabBarFrame.offsetBy(dx: 0, dy: offsetY)
      UIView.animate(withDuration: animationDuration) {
        tabBarController.tabBar.frame = newFrame
      }
    }
  }
}


/// Causes any touch event hits resolving to `self` to be ignored, allowing any superviews or subviews to process touch points.
///
/// In using with `HidingBars`, apply to a tab-bar-attached `UIView` that serves only as a container for other views.
class HidingBarsAttachedView: UIView {

  /// Returns the farthest descendant of the receiver in the view hierarchy (excluding `self`) that contains a specified point.
  ///
  /// - parameter point: A point specified in the receiver’s local coordinate system (bounds).
  /// - parameter: The event that warranted a call to this method. If you are calling this method from outside your event-handling code, you may specify nil.
  /// - returns: The view object that is the farthest descendent of the current view and contains `point`. Returns `nil` if the point lies in `self` or completely outside its view hierarchy.
  override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
    let hitView = super.hitTest(point, with: event)
    return hitView == self ? nil : hitView
  }
}
