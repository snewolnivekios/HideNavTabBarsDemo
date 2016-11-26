//
//  HidingBarsViewController.swift
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
//  - "Swift & the Objective-C Runtime: Method Swizzling", Nate Cook, http://nshipster.com/swift-objc-runtime/
//  - "Method Swizzling", Matt Thompson, http://nshipster.com/method-swizzling/
//  - "Answer: How to implement method swizzling swift 3.0", Tikhonov Alexander, http://stackoverflow.com/a/39562888/4538429
//

import UIKit

/// Extends UIViewController to post NotificationCenter notifications for all view events (will-appear, did-layout-subviews, etc.).
extension UIViewController {

  open override class func initialize() {
    // make sure this isn't a subclass
    guard self === UIViewController.self else { return }
    swizzle(self)
  }

  // For each event, the original UIViewController method is called, followed by the notification center post. See "Invoking _cmd" at http://nshipster.com/method-swizzling/ for more information.

  func swizzled_viewDidLoad() {
    self.swizzled_viewDidLoad()
    NotificationCenter.default.post(name: .UIViewControllerViewDidLoad, object: self)
  }

  func swizzled_viewWillAppear(_ animated: Bool) {
    swizzled_viewWillAppear(animated)
    NotificationCenter.default.post(name: .UIViewControllerViewWillAppear, object: self)
  }

  func swizzled_viewDidAppear(_ animated: Bool) {
    swizzled_viewDidAppear(animated)
    NotificationCenter.default.post(name: .UIViewControllerViewDidAppear, object: self)
  }

  func swizzled_viewWillLayoutSubviews() {
    swizzled_viewWillLayoutSubviews()
    NotificationCenter.default.post(name: .UIViewControllerViewWillLayoutSubviews, object: self)
  }

  func swizzled_viewDidLayoutSubviews() {
    swizzled_viewDidLayoutSubviews()
    NotificationCenter.default.post(name: .UIViewControllerViewDidLayoutSubviews, object: self)
  }

  func swizzled_viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
    swizzled_viewWillTransition(to: size, with: coordinator)
    NotificationCenter.default.post(name: .UIViewControllerViewWillTransition, object: self, userInfo: ["size": size])
  }

  func swizzled_viewWillDisappear(_ animated: Bool) {
    swizzled_viewWillDisappear(animated)
    NotificationCenter.default.post(name: .UIViewControllerViewWillDisappear, object: self)
  }

  func swizzled_viewDidDisappear(_ animated: Bool) {
    swizzled_viewDidDisappear(animated)
    NotificationCenter.default.post(name: .UIViewControllerViewDidDisappear, object: self)
  }
}

/// Extends Notification with identifiers for UIViewController view event notifications.
extension Notification.Name {
  static let UIViewControllerViewDidLoad = Notification.Name("view-controller-view-did-load")
  static let UIViewControllerViewWillAppear = Notification.Name("view-controller-view-will-appear")
  static let UIViewControllerViewDidAppear = Notification.Name("view-controller-view-did-appear")
  static let UIViewControllerViewWillLayoutSubviews = Notification.Name("view-controller-view-will-layout-subviews")
  static let UIViewControllerViewDidLayoutSubviews = Notification.Name("view-controller-view-did-layout-subviews")
  static let UIViewControllerViewWillTransition = Notification.Name("view-controller-view-will-transition")
  static let UIViewControllerViewWillDisappear = Notification.Name("view-controller-view-will-disappear")
  static let UIViewControllerViewDidDisappear = Notification.Name("view-controller-view-did-disappear")
}

/// Swizzles `UIViewController` view event methods with new methods that post `NotificationCenter` notifications `UIViewControllerView___` for `DidLoad`, `WillLayoutSubviews`, etc.
fileprivate let swizzle: (UIViewController.Type) -> () = { UIViewController in

  let swizzleSelectors: [(original: Selector, replacement: Selector)] = [
    (#selector(UIViewController.viewDidLoad), #selector(UIViewController.swizzled_viewDidLoad)),
    (#selector(UIViewController.viewWillAppear(_:)), #selector(UIViewController.swizzled_viewWillAppear(_:))),
    (#selector(UIViewController.viewDidAppear(_:)), #selector(UIViewController.swizzled_viewDidAppear(_:))),
    (#selector(UIViewController.viewWillLayoutSubviews), #selector(UIViewController.swizzled_viewWillLayoutSubviews)),
    (#selector(UIViewController.viewDidLayoutSubviews), #selector(UIViewController.swizzled_viewDidLayoutSubviews)),
    (#selector(UIViewController.viewWillTransition(to:with:)), #selector(UIViewController.swizzled_viewWillTransition(to:with:))),
    (#selector(UIViewController.viewWillDisappear(_:)), #selector(UIViewController.swizzled_viewWillDisappear(_:))),
    (#selector(UIViewController.viewDidDisappear(_:)), #selector(UIViewController.swizzled_viewDidDisappear(_:))),
    ]

  /// Swizzles the `originalSelector` and `replacementSelector` method implementations so that calling the original runs the replacement method logic, and calling the replacement selector runs the original method logic.
  ///
  /// - parameter originalSelector: The original class method selector that will take on the replacement method selector.
  /// - parameter replacementSelector: The replacement method selector that will take on the original class method selector.
  func _swizzle(_ originalSelector: Selector, _ replacementSelector: Selector) {

    let originalMethod = class_getInstanceMethod(UIViewController, originalSelector)
    let replacementMethod = class_getInstanceMethod(UIViewController, replacementSelector)

    // Associate replacement method implementation with original selector, if it exists [a() instead calls b()]
    let didAddMethod = class_addMethod(UIViewController, originalSelector, method_getImplementation(replacementMethod), method_getTypeEncoding(replacementMethod))

    if didAddMethod { // always false for the given original swizzles
      // Associate replacement selector with original method implementation [b() instead calls a()]
      class_replaceMethod(UIViewController, replacementSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else { // original selector already existed; always the case for the given original swizzles
      method_exchangeImplementations(originalMethod, replacementMethod)
    }
  }

  for (originalSelector, replacementSelector) in swizzleSelectors {
    _swizzle(originalSelector, replacementSelector)
  }
}
