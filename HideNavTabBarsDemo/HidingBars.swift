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

protocol HidingBars {

  /// Configures bars behaviors.
  var barsSettings: BarsSettingsModel { get set }
}

extension HidingBars where Self: UIViewController {

  /// Toggles the visibility of the navigation and tab bars in accordance with `barsSettings`.
  func toggleBars() {
    if barsSettings.hideOnAppear {
      barsSettings.hideOnAppear = !barsSettings.barsHidden
    }
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
    barsSettings.autoHideClosure = nil

    // Initiate auto-hide
    if (!hidden || !barsSettings.barsHidden) && barsSettings.hideOnAppear {
      let deadline = DispatchTime.now() + Double(Int64(barsSettings.autoHideDelay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
      barsSettings.autoHideClosure = {
        self.setBars(hidden: true, animated: true)
      }
      DispatchQueue.main.asyncAfter(deadline: deadline) {
        self.barsSettings.autoHideClosure?()
      }
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
    // Source: http://stackoverflow.com/a/27072876/4538429

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

    // Animate the tabBar
    UIView.animate(withDuration: duration) {
      tabBarController.tabBar.frame = frame.offsetBy(dx: 0, dy: offsetY)
    }

    // Animate tabbar-attached view
    if let attachedView = barsSettings.tabBarAttachedView {
      let currFrame = attachedView.frame
      let newFrame = currFrame.offsetBy(dx: 0, dy: hidden ? offsetY : 0)
      UIView.animate(withDuration: duration) {
        attachedView.frame = newFrame
      }
    }
  }
}
