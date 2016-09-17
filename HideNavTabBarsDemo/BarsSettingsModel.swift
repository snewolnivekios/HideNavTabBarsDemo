//
//  BarsSettingsModel.swift
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

/// 
class BarsSettingsModel: LabelDetailSwitchModelProtocol {

  /// Bar settings keyed on setting name.
  var settings: [String: (label: String, detail: String, isOn: Bool)] = [:]

  /// Maps index paths to their corresponding key in `settings`.
  var settingsPaths: [IndexPath: String] = [:]

  /// When true, the tab bar can be hidden.
  var hideTabBar: Bool {
    get { return self.isOn(forName: "\(#function)")! }
    set { set(isOn: newValue, forName: "\(#function)") }
  }

  /// When true, the navigation bar can be hidden.
  var hideNavBar: Bool {
    get { return self.isOn(forName: "\(#function)")! }
    set { set(isOn: newValue, forName: "\(#function)") }
  }

  /// When true, the bars set to hide do so automatically on view-will-appear after an `autoHideDelay`.
  var hideOnAppear: Bool {
    get { return self.isOn(forName: "\(#function)")! }
    set { set(isOn: newValue, forName: "\(#function)") }
  }

  /// When true, the bars show on view-will-appear; otherwise, they remain in their last configuration.
  var showOnAppear: Bool {
    get { return self.isOn(forName: "\(#function)")! }
    set { set(isOn: newValue, forName: "\(#function)") }
  }

  /// The delay before the bars are automatically hidden.
  var autoHideDelay: TimeInterval = 3

  /// The name of the property list containing the initial bars settings values and their table view strings.
  let initialSettingsPlist = "BarsSettings"

  /// The property list key that identifies the setting name.
  let plistNameName = "name"

  /// The property list key that identifies the table view cell label text for a setting.
  let plistLabelName = "label"

  /// The property list key that identifies the table view cell detail text for a setting.
  let plistDetailName = "detail"


  /// Populates `settings` and `settingsPaths` from the bars settings property list.
  init() {
    guard let path = Bundle.main.path(forResource: initialSettingsPlist, ofType: "plist"),
      let initialSettings = NSArray(contentsOfFile: path) as? [[String:String]]
      else { return }
    for (index, setting) in initialSettings.enumerated() {
      settings[setting[plistNameName]!] = (label: setting[plistLabelName]!, detail: setting[plistDetailName]!, isOn: true)
      settingsPaths[IndexPath(row: index, section: 0)] = setting[plistNameName]!
    }
  }


  //////
  // MARK: - LabelDetailSwitchModelProtocol

  /// The observers notified of changes to any switch `isOn` state.
  var observers: [String: SwitchObserver] = [:]

  // See protocol definition.
  private(set) var numberOfSections = 1

  // See protocol definition.
  func numberOfRows(inSection section: Int) -> Int {
    return settings.count
  }

  // See protocol definition.
  func content(for indexPath: IndexPath) -> (label: String, detail: String, isOn: Bool)? {
    if let name = settingsPaths[indexPath],
      let configuration = settings[name] {
      return configuration
    }
    return nil
  }

  // See protocol definition.
  func isOn(forName name: String) -> Bool? {
    if let configuration = settings[name] {
      return configuration.isOn
    }
    return nil
  }

  // See protocol definition.
  func set(isOn: Bool, for indexPath: IndexPath) {
    if let name = settingsPaths[indexPath], let _ = settings[name] {
      settings[name]!.isOn = isOn
      for observer in observers.values {
        observer(name, isOn)
      }
    }
  }

  // See protocol definition.
  func set(isOn: Bool, forName name: String) {
    if let _ = settings[name] {
      settings[name]!.isOn = isOn
      for observer in observers.values {
        observer(name, isOn)
      }
    }
  }

  // See protocol definition.
  func add(observer: @escaping SwitchObserver, forObject object: AnyObject) {
    observers[String(describing: type(of: object))] = observer
  }
}
