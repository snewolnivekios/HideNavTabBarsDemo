//
//  HidingBarsGestureRecognizer.swift
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
//  Attribution:
//  - "Swift & the Objective-C Runtime: Associated Objects", Nate Cook, http://nshipster.com/swift-objc-runtime/
//

import UIKit


/// Adds closure-based initializer `init(block:)` and `addAction(block:)` as complements to selector-based `init(target:action:)` and `addTarget(_:action:)`.
extension UIGestureRecognizer {

  /// The closure called in response to a gesture event.
  typealias ActionBlock = ((UIGestureRecognizer) -> Void)

  /// Identifies the "associated object" gesture action closure.
  private struct AssociatedKeys {
    static var gestureRecognizerBlockDescriptor = "gesture-recognizer-block"
  }

  /// The closure called in response to the configured gesture event. Set to `nil` to remove a previously assigned closure.
  var actionBlock: ActionBlock? {

    get {
      return objc_getAssociatedObject(self, &AssociatedKeys.gestureRecognizerBlockDescriptor) as? ActionBlock
    }

    set {
      if let newValue = newValue {
        objc_setAssociatedObject(
          self,
          &AssociatedKeys.gestureRecognizerBlockDescriptor,
          newValue as Any,
          .OBJC_ASSOCIATION_RETAIN_NONATOMIC
        )
      }
    }
  }

  /// Initializes an allocated gesture-recognizer object with an action block.
  convenience init(block: @escaping ActionBlock) {
    self.init()
    addAction(block: block)
  }

  /// Adds an action block to a gesture-recognizer object.
  ///
  /// Only the last action block added is retained. Remove with `removeActionBlock()`.
  func addAction(block: @escaping ActionBlock) {
    actionBlock = block
    addTarget(self, action: #selector(_actionSelector(sender:)))
  }

  /// Removes an action block from a gesture-recognizer object.
  func removeActionBlock() {
    actionBlock = nil
  }

  /// Wraps a closure in a `Selector`-able method.
  @objc private func _actionSelector(sender: UIGestureRecognizer) { // @objc required for "private"
    actionBlock?(sender)
  }
}
