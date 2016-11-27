//
//  BarsSettingsViewController.swift
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

/// Presents the table view controller-based settings view for navigation and tab bar animations.
class BarsSettingsViewController: UITableViewController {

  /// The data containing switch-configurable navigation and tab bar animation settings.
  var barsSettingsModel = BarsSettingsModel(id: "\(#file)")


  /// Configures cell heights to adjust to autosizing subviews (where Lines is set to 0).
  override func viewDidLoad() {
    tableView.rowHeight = UITableViewAutomaticDimension
    tableView.estimatedRowHeight = 42
  }


  /// Shows the navigation bar.
  override func viewWillAppear(_ animated: Bool) {
    navigationController?.setNavigationBarHidden(false, animated: true)
  }


  /// Returns the number of settings groups.
  override func numberOfSections(in tableView: UITableView) -> Int {
    return barsSettingsModel.numberOfSections
  }


  /// Returns the number of configuration items in the given `section`.
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return barsSettingsModel.numberOfRows(inSection: section)
  }


  /// Returns a cell populated with `barsSettings`-provided data corresponding to the given `indexPath`.
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: "LabelDetailSwitch") as! LabelDetailSwitchCell
    if let content = barsSettingsModel.content(for: indexPath) {
      cell.label.text = content.label
      cell.label.sizeToFit()
      cell.detail.text = content.detail
      cell.switch.isOn = content.isOn
      cell.switch.tag = indexPath.section * 100 + indexPath.row
      cell.switch.addTarget(self, action: #selector(BarsSettingsViewController.switchValueChanged(sender:)), for: .valueChanged)
    }
    return cell
  }

  
  /// Updates the `barsSettings` with the setting corresponding do the given `sender` switch.
  func switchValueChanged(sender: UISwitch) {
    let section = sender.tag / 100
    let row = sender.tag - section
    barsSettingsModel.set(isOn: sender.isOn, for: IndexPath(row: row, section: section))
  }
}
