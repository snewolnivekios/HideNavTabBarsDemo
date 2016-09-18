//
//  SettingsModel.swift
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

/// Provides a model that represents configurable on/off behaviors, to include for each behavior its title, description, and enabled state as would be represented in a table veiw. To this end and conforming to `LabelDetailSwitchModelProtocol`, this includes the essentials for setting, querying, and receiving notifications of changes to a behavior's enabled state.
class SettingsModel: LabelDetailSwitchModelProtocol {


  //////
  // MARK: - Model Data

  let modelId: String

  /// Bar setting strings keyed on setting name.
  var settingStrings: [String: (label: String, detail: String)] = [:]

  /// Bar setting states keyed on setting name.
  var settingStates: [String: Bool] = [:]

  /// Maps index paths to their corresponding key in `settings`.
  var settingsPaths: [IndexPath: String] = [:]


  //////
  // MARK: - Property List Parmaeters

  /// The name of the property list containing the initial bars settings values and their table view strings.
  let initialSettingsPlist = "BarsSettings"

  /// The property list key that identifies the setting name.
  let plistNameName = "name"

  /// The property list key that identifies the table view cell label text for a setting.
  let plistLabelName = "label"

  /// The property list key that identifies the table view cell detail text for a setting.
  let plistDetailName = "detail"


  /// Populates `settingStrings` and `settingsPaths` from the bars settings property list, and initializes all setting states to on.
  /// - parameter id: A unique identifier that distignuishes one model from another.
  init(id: String) {
    modelId = id
    guard let path = Bundle.main.path(forResource: initialSettingsPlist, ofType: "plist"),
      let initialSettings = NSArray(contentsOfFile: path) as? [[String:String]]
      else { return }
    for (index, setting) in initialSettings.enumerated() {
      settingStrings[setting[plistNameName]!] = (label: setting[plistLabelName]!, detail: setting[plistDetailName]!)
      settingStates[setting[plistNameName]!] = true
      settingsPaths[IndexPath(row: index, section: 0)] = setting[plistNameName]!
    }
  }


  //////
  // MARK: - LabelDetailSwitchModelProtocol

  /// The observers notified of changes to any switch `isOn` state.
  var observers: [String: SwitchObserver] = [:]

  /// The number of sections in the table view.
  private(set) var numberOfSections = 1


  /// The number of rows for the identified `section` in the table view.
  func numberOfRows(inSection section: Int) -> Int {
    return settingStrings.count
  }


  /// Returns the label-detail-switch content for the cell at the given `indexPath`.
  /// - parameter indexPath: The cell location within the table view.
  func content(for indexPath: IndexPath) -> (label: String, detail: String, isOn: Bool)? {
    if let name = settingsPaths[indexPath],
      let strings = settingStrings[name],
      let state = settingStates[name] {
      return (strings.label, strings.detail, state)
    }
    return nil
  }


  /// Returns `true` if the model switch state is "on" for the given property `name`, or `nil`, if there is no setting matching `name`.
  /// - parameter name: The name of the setting.
  func isOn(forName name: String) -> Bool? {
    return settingStates[name]
  }


  /// Sets the model switch state for the given `indexPath`.
  /// - parameter isOn: When true, the switch is selected.
  /// - parameter indexPath: The index path of the setting corresponding to the switch.
  func set(isOn: Bool, for indexPath: IndexPath) {
    if let name = settingsPaths[indexPath] {
      set(isOn: isOn, forName: name)
    }
  }


  /// Sets the model switch state for the given property `name` if a setting by that `name` exists.
  /// - parameter isOn: When true, the switch is selected.
  /// - parameter name: The name of the setting corresponding to the switch.
  func set(isOn: Bool, forName name: String) {
    if let _ = settingStrings[name] {
      settingStates[name] = isOn
      for observer in observers.values {
        observer(name, isOn)
      }
    }
  }


  /// Adds the given `observer` closure to the collection of closures that are called when a model switch value changes.
  /// - parameter observer: A closure that receives the setting `name` and switch `isOn` state as arguments.
  /// - parameter object: The object containing `observer`.
  func add(observer: @escaping SwitchObserver, forObject object: AnyObject) {
    observers[String(describing: type(of: object))] = observer
  }
}
