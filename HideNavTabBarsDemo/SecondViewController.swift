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
}

