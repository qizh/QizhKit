//
//  Shape+sugar.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

public import SwiftUI

// MARK: - Clip

extension View {
	@inlinable public func clipCircle() -> some View {
		clipShape(Circle())
	}
}

// MARK: - Fill & Stroke

extension Shape {
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		lineWidth: CGFloat = .one
	) -> some View {
		self
			.stroke(strokeColor, lineWidth: lineWidth)
			.background(self.fill(fillStyle))
	}
	
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		style strokeStyle: StrokeStyle
	) -> some View {
		self
			.stroke(strokeColor, style: strokeStyle)
			.background(self.fill(fillStyle))
	}
}

extension InsettableShape {
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		lineWidth: CGFloat = .one
	) -> some View {
		self
			.strokeBorder(strokeColor, lineWidth: lineWidth)
			.background(self.fill(fillStyle))
	}
	
	public func fill <Fill: ShapeStyle, Stroke: ShapeStyle> (
		_ fillStyle: Fill,
		strokeBorder strokeColor: Stroke,
		style strokeStyle: StrokeStyle
	) -> some View {
		self
			.strokeBorder(strokeColor, style: strokeStyle)
			.background(self.fill(fillStyle))
	}
}

// MARK: - Any Shape

extension Shape {
	public var asAnyShape: AnyShape {
		AnyShape(self)
	}
}

// MARK: - Animatable

public typealias AnimatableTrio<T> = AnimatablePair<AnimatablePair<T, T>, T> where T: VectorArithmetic

public typealias AnimatableQuartet<T> = AnimatablePair<AnimatablePair<T, T>, AnimatablePair<T, T>> where T: VectorArithmetic

public typealias AnimatableCGFloatPair = AnimatablePair<CGFloat, CGFloat>

public typealias AnimatableCGFloatQuartet = AnimatableQuartet<CGFloat>
