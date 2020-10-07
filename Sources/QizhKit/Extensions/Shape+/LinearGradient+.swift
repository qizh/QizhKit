//
//  LinearGradient+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 24.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension LinearGradient {
	@inlinable
	static func vertical(of color: Color, from: CGFloat = 0, to: CGFloat = 1) -> LinearGradient {
		.vertical(from: color, to: color.opacity(0), from: from, to: to)
	}
	
	@inlinable
	static func vertical(
		from color1: Color,
		  to color2: Color,
		       from: CGFloat = 0,
		         to: CGFloat = 1
	) -> LinearGradient {
		LinearGradient(
			gradient: Gradient(
				colors: [
					color1,
					color2
				]
			),
			startPoint: UnitPoint(x: 0, y: from),
			endPoint: UnitPoint(x: 0, y: to)
		)
	}
	
	@inlinable
	static func horizontal(of color: Color, from: CGFloat = 0, to: CGFloat = 1) -> LinearGradient {
		LinearGradient(
			gradient: Gradient(
				colors: [
					color,
					color.opacity(0)
				]
			),
			startPoint: UnitPoint(x: from, y: 0),
			  endPoint: UnitPoint(x: to,   y: 0)
		)
	}
}
