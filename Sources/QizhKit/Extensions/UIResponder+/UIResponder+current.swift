//
//  UIResponder+current.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 16.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import UIKit

// @available(iOSApplicationExtension, unavailable)
public extension UIResponder {
	private weak static var _currentFirstResponder: UIResponder? = nil
	
	static var current: UIResponder? {
		UIResponder._currentFirstResponder = nil
		UIApplication.shared.sendAction(#selector(findFirstResponder(sender:)), to: nil, from: nil, for: nil)
		return UIResponder._currentFirstResponder
	}
	
	@inlinable var currentFirstResponder: UIResponder? {
		UIResponder.current
	}
	
	@objc internal func findFirstResponder(sender: AnyObject) {
		UIResponder._currentFirstResponder = self
	}
}
