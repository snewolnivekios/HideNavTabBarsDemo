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


/// A `UIViewController` conforming to this protocol gains the ability to hide and show either or both the navigation and tab bars in response to a user's gesture.
///
/// To utilize this functionality:
///
/// 1. Conform a view controller to this protocol (by providing the `barsSettings` property that configures the hiding bars behavior).
/// 1. In `viewDidLoad(_:)`, add a call to `activateHidingBars(attachedView:gestureRecognizer:)`, with the attached view optionally subclassing `HidingBarsAttachedView` and the gesture recognizer optionally configured beyond an empty initializer.
///
/// The `HidingBarsAttachedView`, as a collection of subviews, allows you to anchor more than one view to the tab bar while keeping that collection view itself from capturing the touch events used to toggle the visibility of the bars.
///
/// The gesture recognizer could simply be given as `UITapGestureRecognizer()`:
///
///       activateHidingBars(attachedView: view.viewWithTag(42), gestureRecognizer: UITapGestureRecognizer())
///
/// or as a configured recognizer:
///
///       @IBOutlet weak var button: UIButton!
///       let gr = UITapGestureRecognizer()
///       gr.numberOfTouchesRequired = 2
///       activateHidingBars(attachedView: button, gestureRecognizer: gr)
///
/// Note that in both cases, an gesture target-action is not required, although it is allowable:
///
///       @IBOutlet weak var myView: UIView!
///       let myRecognizer = UITapGestureRecognizer(target: self, action: #selector(someAction(sender:))
///       activateHidingBars(attachedView: myView, gestureRecognizer: myRecognizer)
///
/// In this case, the gesture recognizer will call your action method in addition to toggling the visibility of the bars as configured.

protocol HidingBars: class {

  /// Configures bars behaviors.
  var barsSettings: HidingBarsSettings { get set }
}

extension HidingBars where Self: UIViewController {

  /// Activates the hiding bars behavior by adding responders to update bar states in response to several `UIViewController` events. 
  func activateHidingBars(attachedView: UIView?, gestureRecognizer: UIGestureRecognizer) {

    gestureRecognizer.addAction() { sender in
      self.toggleBars()
    }

    barsSettings.tabBarAttachedView = attachedView
    view.addGestureRecognizer(gestureRecognizer)

    NotificationCenter.default.addObserver(forName: .UIViewControllerViewWillAppear, object: self, queue: nil) {
      notification in
      self.barsSettings.autoHideOverride = false
      self.setBars(hidden: self.barsSettings.showOnAppear ? false : self.barsSettings.barsHidden, animated: false)
    }

    NotificationCenter.default.addObserver(forName: .UIViewControllerViewWillTransition, object: self, queue: nil) {
      notification in
      if let size = notification.userInfo?["size"] as? CGSize {
        self.updateBars(for: .viewWillTransition(toSize: size))
      }
    }

    NotificationCenter.default.addObserver(forName: .UIViewControllerViewWillTransition, object: self, queue: nil) {
      notification in
      self.updateBars(for: .viewWillLayoutSubviews)
    }

    NotificationCenter.default.addObserver(forName: .UIViewControllerViewWillDisappear, object: self, queue: nil) {
      notification in
      self.updateBars(for: .viewWillDisappear)
    }
  }


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
        setBars(hidden: barsSettings.showOnAppear ? false : barsSettings.barsHidden, animated: true)
      }

    case .viewWillLayoutSubviews:
      setBars(hidden: barsSettings.barsHidden, animated: false)

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
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.01) { // allow time for view frames to update
        self.setTabBar(hidden: hidden, animated: animated)
      }
    }

    // If bars are showing, initiate auto-hide if feature is enabled and not overriden by user explicilty showing them
    if !hidden && barsSettings.autoHideDelay != nil && !barsSettings.autoHideOverride {
      barsSettings.autoHideWorkItem = DispatchWorkItem {
        self.setBars(hidden: true, animated: true)
      }
      DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + barsSettings.autoHideDelay!, execute: barsSettings.autoHideWorkItem!)
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
    var tabBarFrame = tabBarController.tabBar.frame
    let offsetY = (hidden ? 1 : -1) * tabBarFrame.size.height

    let animationDuration: TimeInterval = (animated ? 0.25 : 0.0)
    let tabBarIsVisible = tabBarFrame.origin.y < self.view.frame.maxY

    // Reposition the tabBar if the current state does not match the to state
    if tabBarIsVisible == hidden {
      tabBarFrame = tabBarFrame.offsetBy(dx: 0, dy: offsetY)
      UIView.animate(withDuration: animationDuration) {
        tabBarController.tabBar.frame = tabBarFrame
      }
    }

    // Position the tabbar-attached view
    if let attachedView = barsSettings.tabBarAttachedView {
      let y = tabBarFrame.origin.y - barsSettings.tabBarAttachedViewGap - attachedView.frame.size.height
      var attachedViewFrame = attachedView.frame
      attachedViewFrame.origin.y = y
      UIView.animate(withDuration: animationDuration) {
        attachedView.frame = attachedViewFrame
      }
    }
  }
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

  /// To be called on `viewWillLayoutSubviews()`, restores the tab bar-hidden position of the tab bar-attached view.
  case viewWillLayoutSubviews

  /// To be called on `viewWillDisappear(_:)`, cancels any pending auto-hide.
  case viewWillDisappear
}


/// A type conforming to this protocol provides configurable items for the `HidingBars` protocol and a mechanism for maintaining state needed for its operation.
protocol HidingBarsSettings {

  // MARK: Configuration

  /// When `true`, the tab bar can be hidden.
  var hideTabBar: Bool { get }

  /// When `true`, the navigation bar can be hidden.
  var hideNavBar: Bool { get }

  /// When `true`, the bars show on view-will-appear and will-transition; otherwise, they remain in their current configuration.
  var showOnAppear: Bool { get }

  /// If non-`nil`, the bars will automatically hide after `autoHideDelay`.
  var autoHideDelay: TimeInterval? { get }

  /// The view animated with the tab bar. This view may be constrained either to the bottom layout guide or the bottom edge of the view.
  var tabBarAttachedView: UIView? { get set }

  /// The distance between the bottom of the tab bar-attached view and the top of the tab bar.
  var tabBarAttachedViewGap: CGFloat { get set }


  // MARK: State

  /// Set to `true` when the user has manually shown the bars after they were automatically hidden.
  var autoHideOverride: Bool { get set }

  /// Set to `true` when the bars are currently hidden; `false`, otherwise.
  var barsHidden: Bool { get set }

  /// Hides the bars if not cancelled before the `autoHideDelay` expires.
  ///
  /// Auto-hide is cancelled when the bars state is changed and when the view disappears.
  var autoHideWorkItem: DispatchWorkItem? { get set }
}


/// The settings required by the `HidingBars` protocol.
struct DefaultHidingBarsSettings: HidingBarsSettings {

  // MARK: Configuration
  var hideTabBar = true
  var hideNavBar = true
  var hideOnAppear = true
  var showOnAppear = true
  var autoHideDelay: TimeInterval? = 3
  var tabBarAttachedView: UIView?
  var tabBarAttachedViewGap: CGFloat = 0

  // MARK: State
  var autoHideOverride = false
  var barsHidden = false
  var autoHideWorkItem: DispatchWorkItem?
}


/// Causes any touch event hits resolving to `self` to be ignored, allowing any superviews or subviews to process touch points.
///
/// In using with `HidingBars`, apply to a tab-bar-attached `UIView` that serves as a container for other views.
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
