//
//  Angle+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Double {
	@inlinable var degrees: Angle { .degrees(self) }
	@inlinable var radians: Angle { .radians(self) }
}

public extension BinaryInteger {
	@inlinable var degrees: Angle { .degrees(Double(self)) }
	@inlinable var radians: Angle { .radians(Double(self)) }
}

public extension BinaryFloatingPoint {
	@inlinable var degrees: Angle { .degrees(Double(self)) }
	@inlinable var radians: Angle { .radians(Double(self)) }
}

extension Angle {
	// public static let zero:     Angle = .degrees(.zero)
	public static let opposite: Angle = .radians(.pi)
	
	@inlinable public var opposite:   Angle { self + .radians(.pi) }
	@inlinable public var circle:     Angle { self + .radians(Double.pi.doubled) }
	@inlinable public var circleBack: Angle { self - .radians(Double.pi.doubled) }
}

extension Angle: @retroactive CustomStringConvertible {
	@inlinable public var description: String { degrees.s1 + .degrees }
}
