//
//  UIFont+system.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 12.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

#if canImport(UIKit)
import UIKit

public extension UIFont {
	static func size(_ size: CGFloat, _ weight: UIFont.Weight = .regular) -> UIFont {
		systemFont(ofSize: size, weight: weight)
	}
	
	static func ultraLight(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .ultraLight) }
	static func       thin(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .thin) }
	static func      light(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .light) }
	static func    regular(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .regular) }
	static func     medium(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .medium) }
	static func   semibold(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .semibold) }
	static func       bold(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .bold) }
	static func      heavy(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .heavy) }
	static func      black(_ size: CGFloat) -> UIFont { systemFont(ofSize: size, weight: .black) }
}
#endif
