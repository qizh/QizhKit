//
//  ClipTransition.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct ClipRectangleModifier: ViewModifier {
	private let side: Side
	private let factor: Factor
	
	public init(_ side: Side, factor: Factor) {
		self.side = side
		self.factor = factor
	}
	
	public func body(content: Content) -> some View {
		content
			.clipShape(side.shape(factor: factor))
	}
	
	public enum Side {
		case top
		case bottom
		case leading
		case trailing
		
		public func shape(factor: Factor) -> some Shape {
			switch self {
			case .top:      return ScalableRectangle(.top,      .y(factor))
			case .bottom:   return ScalableRectangle(.bottom,   .y(factor))
			case .leading:  return ScalableRectangle(.leading,  .x(factor))
			case .trailing: return ScalableRectangle(.trailing, .x(factor))
			}
		}
	}
}

public struct ScalableRectangle: Shape {
	private let anchor: UnitPoint
	private var factor: AxisFactor
	
	public init(_ anchor: UnitPoint, _ factor: AxisFactor) {
		self.anchor = anchor
		self.factor = factor
	}
	
	public var animatableData: AxisFactor {
		get { factor }
		set { factor = newValue }
	}
	
	public func path(in rect: CGRect) -> Path {
		Rectangle()
			.scale(x: factor.horizontal.cg, y: factor.vertical.cg, anchor: anchor)
			.path(in: rect)
	}
}

public extension AnyTransition {
	static func clip(_ side: ClipRectangleModifier.Side) -> AnyTransition {
		AnyTransition.modifier(
			  active: ClipRectangleModifier(side, factor: .zero),
			identity: ClipRectangleModifier(side, factor: .one)
		)
	}
}
