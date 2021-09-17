//
//  Shape+sugar.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	@inlinable public func clipCircle() -> some View {
		clipShape(Circle())
	}
}

extension Shape {
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeStyle: Stroke,
		lineWidth: CGFloat = .one
	) -> some View {
		self
			.stroke(strokeStyle, lineWidth: lineWidth)
			.background(self.fill(fillStyle))
	}
}

extension InsettableShape {
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeStyle: Stroke,
		lineWidth: CGFloat = .one
	) -> some View {
		self
			.strokeBorder(strokeStyle, lineWidth: lineWidth)
			.background(self.fill(fillStyle))
	}
}
