//
//  SecondViewController.swift
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

/// Demonstrates how to customize the bar settings for a subclass of `BarsViewController`.
class SecondViewController: BarsViewController {

  /// Sets non-default navigation and tab bar behavior.
  override func viewDidLoad() {
    super.viewDidLoad()
    model.set(isOn: false, forName: "hideTabBar")
    model.set(isOn: false, forName: "hideOnAppear")
  }


  /// As the target action for the `LabelDetailSwitchModelProtocol` (`BarsSettingsModel`) switch value changes, if the bars are currently hidden, shows or hides them in accordance with the change to their corresponding switch setting.
  ///
  /// For example, if both bars are hidden and the user turns off hiding for the tab bar, this  shows the tab bar. If they turn on hiding for the tab bar, it hides the tab bar.
  ///
  /// If the bars are not currently hidden, changes to the settings have no effect.
  /// - parameter name: The identifier for the setting.
  /// - parameter isOn: Mirrors the changed `isOn` value of the corresponding `UISwitch`.
  override func changedSetting(with name: String, isOn: Bool) {
    super.changedSetting(with: name, isOn: isOn)

    // If the bars have been manually shown, leave them shown
    guard barsHidden else { return }

    // Otherwise, update bar visibility based on new setting
    switch name {
    case "hideTabBar":
      setTabBar(hidden: isOn, animated: true)
    case "hideNavBar":
      setNavBar(hidden: isOn, animated: true)
    default:
      break
    }
  }
}

