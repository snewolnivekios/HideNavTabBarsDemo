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
class BarsViewController: UIViewController, HidingBars {

  /// Enables user changes to and persistence of `barsSettings`.
  var barsSettingsModel: BarsSettingsModel

  /// A `HidingBars` protocol property, configures bar behaviors.
  var barsSettings: HidingBarsSettings {
    get { return barsSettingsModel }
    set { barsSettingsModel = barsSettings as! BarsSettingsModel }
  }

  /// Initializes the `barsSettingsModel`.
  required init?(coder aDecoder: NSCoder) {
    barsSettingsModel = BarsSettingsModel(id: String(describing: type(of: self))) // e.g., "FirstViewController"
    super.init(coder: aDecoder)
  }


  /// Establishes self as an observer for changes to `barsSettingsModel` values.
  override func viewDidLoad() {
    super.viewDidLoad()
    barsSettingsModel.add(observer: changedSetting(with:isOn:), forObject: self)
    updateBars(for: .viewDidLoad(attachedView: nil, recognizer: UITapGestureRecognizer(target: self, action: #selector(_toggleBars(sender:)))))
  }


  /// Displayes the navigation and tab bars in accordance with the `BarsSettingsModel` settings and installs tap gesture recognizer notifications to `toggleBars(sender:)`.
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


  /// Toggles the bars visibility in response to a tap gesture.
  func _toggleBars(sender: UITapGestureRecognizer) {
    toggleBars()
  }


  /// Injects the current `BarsSettingsModel` into the destination `BarsSettingsViewController` and shows the tab bar for use by that view.
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if let destination = segue.destination as? BarsSettingsViewController {
      destination.barsSettingsModel = barsSettingsModel
    }
    setTabBar(hidden: false, animated: true)
  }


  /// As the target action for the `BarsSettingsModel` switch value changes, updates the temporary user-override `hideOnAppear` with that given by the setting.
  ///
  /// - parameter name: The identifier for the setting.
  /// - parameter isOn: Mirrors the changed `isOn` value of the corresponding `UISwitch`.
  func changedSetting(with name: String, isOn: Bool) {
//    if name == "hideOnAppear" {
//      barsSettings.set(isOn: isOn, forName: name)
//    }
  }
}
