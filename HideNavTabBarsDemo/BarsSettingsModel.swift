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

/// Adds convenience properties to `SettingsModel` specific to configuring behaviors of the navigation and tab bars.
class BarsSettingsModel: SettingsModel {

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

}
