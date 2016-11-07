//
//  ThirdViewController.swift
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

/// Adds hiding bars functionality without dependency upon `BarsViewController` or `BarsSettingsModel`.
class ThirdViewController: UIViewController, HidingBars {

  /// The settings required by the `HidingBars` protocol.
  struct DefaultBarsSettings: HidingBarsSettings {

    // Configuration
    var hideTabBar = true
    var hideNavBar = true
    var hideOnAppear = true
    var showOnAppear = true
    var autoHideDelay: TimeInterval = 3
    var tabBarAttachedView: UIView?

    // State
    var autoHideOverride = false
    var barsHidden = false
    var autoHideWorkItem: DispatchWorkItem?
  }

  /// A `HidingBars` protocol property, configures bar behaviors.
  var barsSettings: HidingBarsSettings = DefaultBarsSettings()


  /// Assigns the view to animate with the tab bar.
  override func viewDidLoad() {
    super.viewDidLoad()
    updateBars(for: .viewDidLoad(attachedView: view.viewWithTag(42), recognizer: UITapGestureRecognizer(target: self, action: #selector(_toggleBars(sender:)))))
  }


  /// Shows the bars if `showOnAppear` is enabled; otherwise, shows them according to their last `barsHidden` state.
  override func viewWillAppear(_ animated: Bool) {
    updateBars(for: .viewWillAppear)
  }


  /// Makes the bars visible when the device rotates, auto-hiding in accordance with the auto-hide setting.
  override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    updateBars(for: .viewWillTransition)
  }


  /// Cancels any pending auto-hide timers.
  override func viewWillDisappear(_ animated: Bool) {
    updateBars(for: .viewWillDisappear)
  }


  /// In response to a tap gesture, hides/shows the bars.
  func _toggleBars(sender: UITapGestureRecognizer) {
    toggleBars()
  }
}
