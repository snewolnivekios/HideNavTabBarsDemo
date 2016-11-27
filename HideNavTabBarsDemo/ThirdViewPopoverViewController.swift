//
//  ThirdViewPopoverViewController.swift
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

class ThirdViewPopoverViewController: UIViewController {

  var hideStatusBar = false

  override func viewWillAppear(_ animated: Bool) {
    hideStatusBar = UIApplication.shared.keyWindow?.traitCollection.horizontalSizeClass == .compact
    UIView.animate(withDuration: 0.5) {
      self.setNeedsStatusBarAppearanceUpdate()
    }
  }

  override var prefersStatusBarHidden: Bool {
    return hideStatusBar
  }

}
