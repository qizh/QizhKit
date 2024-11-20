//
//  RelativeDimension.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public enum RelativeDimension: ExpressibleByFloatLiteral,
							   ExpressibleByIntegerLiteral,
							   Sendable
{
	case maximum
	case exactly(_ value: CGFloat)
	case minimum(_ extraPadding: CGFloat)
	
	public static let minimum: Self = .minimum(.zero)
	
	public init(  floatLiteral value: Double) { self = .exactly(CGFloat(value)) }
	public init(integerLiteral value: Int)    { self = .exactly(value.cg) }
	
	public var value: CGFloat? {
		switch self {
		case .exactly(let value): 	value
		default: 			  		nil
		}
	}
	
	public var maxValue: CGFloat? {
		switch self {
		case .maximum: .infinity
		default: 	    nil
		}
	}
	
	public var extraPadding: CGFloat {
		switch self {
		case .minimum(let extraPadding): extraPadding
		default: 						.zero
		}
	}
}

extension RelativeDimension: EasyComparable {
	public func `is`(_ other: RelativeDimension) -> Bool {
		switch (self, other) {
		case (.maximum, .maximum): 	true
		case (.exactly, .exactly): 	true
		case (.minimum, .minimum): 	true
		default: 					false
		}
	}
	
	@inlinable public var isMaximum: Bool { self.is(.maximum) }
	@inlinable public var isExact: Bool   { self.is(.exactly(.zero)) }
	@inlinable public var isMinimum: Bool { self.is(.minimum) }
}
