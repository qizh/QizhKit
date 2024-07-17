//
//  SwiftUIView.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.03.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct Rotated <Wrapped: View>: View {
	private let wrapped: Wrapped
	private let angle: Angle

	@State private var size: CGSize = .zero
	
	public init(_ view: Wrapped, angle: Angle = .degrees(-90)) {
		self.wrapped = view
		self.angle = angle
	}
	
	public var body: some View {
		wrapped
			.fixedSize()
			.background {
				GeometryReader { geometry -> Color in
					executeAssign(geometry.size, to: $size)
					return Color.clear
				}
			}
			.rotationEffect(angle)
			.size(rotatedFrame.size)
	}
	
	private var rotatedFrame: CGRect {
		CGRect(.zero, size)
			.offsetBy(
				dx: -size.width.half,
				dy: -size.height.half
			)
			.applying(
				CGAffineTransform(
					rotationAngle: CGFloat(angle.radians)
				)
			)
			.integral
	}
}

public extension View {
	@inlinable
	func rotated(_ angle: Angle) -> some View {
		Rotated(self, angle: angle)
	}
}
