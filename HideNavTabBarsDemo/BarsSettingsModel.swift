//
//  BarsSettingsModel.swift
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

/// Conforms `HidingBarsSettings` to a `SettingsModel`, adding a framework for configuration item mutability and persistence.
class BarsSettingsModel: SettingsModel, HidingBarsSettings, CustomStringConvertible {

  // MARK: Configuration

  var hideTabBar: Bool {
    get { return self.isOn(forName: "\(#function)")! }
    set { set(isOn: newValue, forName: "\(#function)") }
  }

  var hideNavBar: Bool {
    get { return self.isOn(forName: "\(#function)")! }
    set { set(isOn: newValue, forName: "\(#function)") }
  }

  var hideOnAppear: Bool {
    get { return self.isOn(forName: "\(#function)")! }
    set { set(isOn: newValue, forName: "\(#function)") }
  }

  var showOnAppear: Bool {
    get { return self.isOn(forName: "\(#function)")! }
    set { set(isOn: newValue, forName: "\(#function)") }
  }

  var autoHideDelay: TimeInterval? = 3

  /// A string representation of the configuration (non-state) items.
  var description: String {
    return "\(#function): hideNavBar = \(hideNavBar); hideTabBar = \(hideTabBar); showOnAppear = \(showOnAppear); hideOnAppear = \(hideOnAppear); autoHideDelay = \(autoHideDelay)"
  }

  var autoHideOverride: Bool = false
  
  var tabBarAttachedView: UIView?

  // MARK: State

  var tabBarAttachedViewGap: CGFloat = 0
  var barsHidden: Bool = false
  var autoHideWorkItem: DispatchWorkItem?
}
