//
//  UIScreen+shortcuts.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 24.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

#if os(iOS)
public extension UIScreen {
	@inlinable static var width  : CGFloat { main.bounds.width }
	@inlinable static var height : CGFloat { main.bounds.height }
	@inlinable static var size   : CGSize  { main.bounds.size }
}
#endif

public extension UIApplication {
	@inlinable
	func endEditing() {
		sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
	}
}
