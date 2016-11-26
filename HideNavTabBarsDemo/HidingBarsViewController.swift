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
    swizzled(self)
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
fileprivate let swizzled: (UIViewController.Type) -> () = { viewController in

  let swizzles: [(original: Selector, swizzled: Selector)] = [
    (#selector(viewController.viewDidLoad), #selector(viewController.swizzled_viewDidLoad)),
    (#selector(viewController.viewWillAppear(_:)), #selector(viewController.swizzled_viewWillAppear(_:))),
    (#selector(viewController.viewDidAppear(_:)), #selector(viewController.swizzled_viewDidAppear(_:))),
    (#selector(viewController.viewWillLayoutSubviews), #selector(viewController.swizzled_viewWillLayoutSubviews)),
    (#selector(viewController.viewDidLayoutSubviews), #selector(viewController.swizzled_viewDidLayoutSubviews)),
    (#selector(viewController.viewWillTransition(to:with:)), #selector(viewController.swizzled_viewWillTransition(to:with:))),
    (#selector(viewController.viewWillDisappear(_:)), #selector(viewController.swizzled_viewWillDisappear(_:))),
    (#selector(viewController.viewDidDisappear(_:)), #selector(viewController.swizzled_viewDidDisappear(_:))),
    ]

  func swizzle(original originalSelector: Selector, swizzled swizzledSelector: Selector) {
    let originalMethod = class_getInstanceMethod(viewController, originalSelector)
    let swizzledMethod = class_getInstanceMethod(viewController, swizzledSelector)

    let didAddMethod = class_addMethod(viewController, originalSelector, method_getImplementation(swizzledMethod), method_getTypeEncoding(swizzledMethod))

    if didAddMethod {
      class_replaceMethod(viewController, swizzledSelector, method_getImplementation(originalMethod), method_getTypeEncoding(originalMethod))
    } else {
      method_exchangeImplementations(originalMethod, swizzledMethod)
    }
  }

  for (original, swizzled) in swizzles {
    swizzle(original: original, swizzled: swizzled)
  }
}