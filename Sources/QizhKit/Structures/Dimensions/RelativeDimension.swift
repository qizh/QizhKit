//
//  RelativeDimension.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public enum RelativeDimension: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
	case maximum
	case exactly(_ value: CGFloat)
	case minimum
	
	public init(  floatLiteral value: Double) { self = .exactly(CGFloat(value)) }
	public init(integerLiteral value: Int)    { self = .exactly(value.cg) }
	
	public var value: CGFloat? {
		switch self {
		case .exactly(let v): return v
		default: 			  return nil
		}
	}
	
	public var maxValue: CGFloat? {
		switch self {
		case .maximum: return .infinity
		default: 	   return nil
		}
	}
}

extension RelativeDimension: EasyComparable {
	public func `is`(_ other: RelativeDimension) -> Bool {
		switch (self, other) {
		case (.maximum, .maximum): return true
		case (.exactly, .exactly): return true
		case (.minimum, .minimum): return true
		default: return false
		}
	}
	
	@inlinable public var isMaximum: Bool { self.is(.maximum) }
	@inlinable public var isExact: Bool   { self.is(.exactly(.zero)) }
	@inlinable public var isMinimum: Bool { self.is(.minimum) }
}
