//
//  FirstViewController.swift
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

/// Demonstrates how to customize the settings for a `BarsViewController`.
///
/// Customizations include disabling persistence and defaulting the settings to hide-navigatino-bar: on; hide-tab-bar: off; hide-on-appear: off; show-on-appear: on.
class FirstViewController: BarsViewController {

  /// The view that animates with the tab bar.
  @IBOutlet weak var tabBarAttachedView: UIView!

  /// Sets non-default navigation and tab bar behavior.
  override func viewDidLoad() {
    super.viewDidLoad()
    barsSettingsModel.persisted = false
    barsSettingsModel.set(isOn: true, forName: "hideTabBar")
    barsSettingsModel.set(isOn: true, forName: "hideOnAppear")
    barsSettings.tabBarAttachedView = tabBarAttachedView
  }
}
