//
//  ShapeBuilder.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 15.02.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//  Author: https://stackoverflow.com/a/71085711/674741
//

import SwiftUI

@resultBuilder
public struct ShapeBuilder {
	public static func buildBlock<C0: Shape>(_ c0: C0) -> C0 { c0 }
}

extension ShapeBuilder {
	public static func buildBlock() -> EmptyShape { EmptyShape() }
}

public struct EmptyShape: Shape {
	public func path(in rect: CGRect) -> Path { Path() }
}

extension ShapeBuilder {
	public static func buildOptional<C0: Shape>(_ c0: C0?) -> OptionalShape<C0> {
		OptionalShape(c0)
	}
}

extension ShapeBuilder {
	public static func buildLimitedAvailability(_ component: some Shape) -> AnyShape {
		AnyShape(component)
	}
}

public struct OptionalShape<Content: Shape>: Shape {
	public let content: Content?

	public init(_ content: Content?) {
		self.content = content
	}

	public func path(in rect: CGRect) -> Path {
		content?.path(in: rect) ?? Path()
	}
}

extension ShapeBuilder {
	public static func buildEither<First: Shape, Second: Shape>(first: First) -> EitherShape<First, Second> {
		.first(first)
	}

	public static func buildEither<First: Shape, Second: Shape>(second: Second) -> EitherShape<First, Second> {
		.second(second)
	}
}

public enum EitherShape<First: Shape, Second: Shape>: Shape {
	case first(First)
	case second(Second)

	public func path(in rect: CGRect) -> Path {
		switch self {
		case .first(let first): first.path(in: rect)
		case .second(let second): second.path(in: rect)
		}
	}
}

extension ShapeBuilder {
	public static func buildBlock<C0: Shape, C1: Shape>(_ c0: C0, _ c1: C1) -> Tuple2Shape<C0, C1> {
		Tuple2Shape(c0, c1)
	}
}

public struct Tuple2Shape<C0: Shape, C1: Shape>: Shape {
	public let tuple: (C0, C1)

	public init(_ c0: C0, _ c1: C1) {
		tuple = (c0, c1)
	}

	public func path(in rect: CGRect) -> Path {
		var path = tuple.0.path(in: rect)
		path.addPath(tuple.1.path(in: rect))
		return path
	}
}

extension ShapeBuilder {
	public static func buildBlock<C0: Shape, C1: Shape, C2: Shape>(_ c0: C0, _ c1: C1, _ c2: C2) -> Tuple3Shape<C0, C1, C2> {
		Tuple3Shape(c0, c1, c2)
	}
}

public struct Tuple3Shape<C0: Shape, C1: Shape, C2: Shape>: Shape {
	public let tuple: (C0, C1, C2)

	public init(_ c0: C0, _ c1: C1, _ c2: C2) {
		tuple = (c0, c1, c2)
	}

	public func path(in rect: CGRect) -> Path {
		var path = tuple.0.path(in: rect)
		path.addPath(tuple.1.path(in: rect))
		path.addPath(tuple.2.path(in: rect))
		return path
	}
}

// MARK: Preview
#if DEBUG
fileprivate struct Test: View {
	var body: some View {
		shapeTest
			.fill(.clear, strokeBorder: .pink, lineWidth: 3)
			.aspectRatio(contentMode: .fit)
			.padding()
	}
	
	@ShapeBuilder
	private var shapeTest: some Shape {
		Circle()
		Rectangle()
		Capsule()
			.scale(y: 0.5, anchor: .center)
	}
}

#Preview("Shape Test") {
	Test()
}
#endif
