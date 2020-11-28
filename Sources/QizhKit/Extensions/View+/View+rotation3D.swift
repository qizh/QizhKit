//
//  View+rotation3D.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.11.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct RotationAxis {
	public let x: CGFloat
	public let y: CGFloat
	public let z: CGFloat
	
	public init(x: CGFloat = .zero, y: CGFloat = .zero, z: CGFloat = .zero) {
		self.x = x
		self.y = y
		self.z = z
	}
	
	public var tri: (x: CGFloat, y: CGFloat, z: CGFloat) {
		(x: x, y: y, z: z)
	}
	
	@inlinable public static func x(_ value: CGFloat) -> Self {
		.init(x: value, y: .zero, z: .zero)
	}
	@inlinable public static func y(_ value: CGFloat) -> Self {
		.init(x: .zero, y: value, z: .zero)
	}
	@inlinable public static func z(_ value: CGFloat) -> Self {
		.init(x: .zero, y: .zero, z: value)
	}
	@inlinable public static var x: Self { x(.one) }
	@inlinable public static var y: Self { y(.one) }
	@inlinable public static var z: Self { z(.one) }
}

public extension View {
	@inlinable func rotation3DEffect(
		_ angle: Angle,
		axis: RotationAxis,
		anchor: UnitPoint = .center,
		anchorZ: CGFloat = 0,
		perspective: CGFloat = 1
	) -> some View {
		rotation3DEffect(
			angle,
			axis: axis.tri,
			anchor: anchor,
			anchorZ: anchorZ,
			perspective: perspective
		)
	}
}
