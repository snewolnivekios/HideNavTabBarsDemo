//
//  LabelDetailSwitchModelProtocol.swift
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

/// A closure that receives notification of a change in the on/off state of a particular setting.
/// - parameter name: The name of the setting.
/// - parameter isOn: Mirrors the cell's new `UISwitch isOn` state.
typealias SwitchObserver = (_ name: String, _ isOn: Bool) -> Void


/// Types conforming to this protocol provide the essentials for populating, querying, and receiving notifications from a model that backs a table view cell with label text, detail text, and a switch control.
protocol LabelDetailSwitchModelProtocol {

  /// The number of sections in the table view.
  var numberOfSections: Int { get }

  /// The number of rows for the identified `section` in the table view.
  func numberOfRows(inSection section: Int) -> Int

  /// Returns the label-detail-switch content for the cell at the given `indexPath`.
  /// - parameter indexPath: The cell location within the table view.
  func content(for indexPath: IndexPath) -> (label: String, detail: String, isOn: Bool)?

  /// Returns `true` if the model switch state is "on" for the given property `name`, or `nil`, if there is no property matching `name`.
  /// - parameter name: The name of the setting.
  func isOn(forName name: String) -> Bool?

  /// Sets the model switch state for the given property `name` if a setting by that `name` exists.
  /// - parameter isOn: When true, the switch is selected.
  /// - parameter name: The name of the setting corresponding to the switch.
  mutating func set(isOn: Bool, forName name: String)

  /// Sets the model switch state for the given `indexPath`.
  /// - parameter isOn: When true, the switch is selected.
  /// - parameter indexPath: The index path of the setting corresponding to the switch.
  mutating func set(isOn: Bool, for indexPath: IndexPath)

  /// Adds the given `observer` closure to the collection of closures that are called when a model switch value changes.
  /// - parameter observer: A closure that receives the setting `name` and switch `isOn` state as arguments.
  /// - parameter object: The object containing `observer`.
  mutating func add(observer: @escaping SwitchObserver, forObject object: Any)
}


/// The prototype label-detail-switch cell.
class LabelDetailSwitchCell: UITableViewCell {

  /// Prominent label text within the cell.
  @IBOutlet weak var label: UILabel!

  /// Secondary detail text within the cell.
  @IBOutlet weak var detail: UILabel!

  /// The switch within the cell that indicates an on/off state.
  @IBOutlet weak var `switch`: UISwitch!
}
