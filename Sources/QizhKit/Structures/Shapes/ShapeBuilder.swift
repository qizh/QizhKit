//
//  ShapeBuilder.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 15.02.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//  Author: https://stackoverflow.com/a/71085711/674741
//

import SwiftUI

// MARK: - Helper Shapes



// MARK: Any

/// A type-erased `Shape`.
///
/// SwiftUI provides `AnyShapeStyle`, but a type-erased `Shape` is still useful for
/// result-builder scenarios (e.g. `buildLimitedAvailability`).
public struct AnyShape: Shape {
	private let _path: @Sendable (CGRect) -> Path

	public init<S: Shape>(_ shape: S) {
		self._path = { rect in
			shape.path(in: rect)
		}
	}

	public func path(in rect: CGRect) -> Path {
		_path(rect)
	}
}

// MARK: Insetted

/// A `Shape` wrapper that applies an inset (`InsettableShape.inset(by:)`) lazily.
///
/// You can use it directly:
/// ```swift
/// let s = InsettedShape(Circle(), by: 12)
/// ```
/// Or as a property wrapper when you want to store an insettable shape plus its inset:
/// ```swift
/// @InsettedShape(by: 8) var shape = Capsule()
/// ```
/// - Note: This wrapper conforms to both `Shape` and `InsettableShape`.
@propertyWrapper
public struct InsettedShape<S: InsettableShape>: InsettableShape, Updatable {
	public let wrappedValue: S
	public fileprivate(set) var insetAmount: CGFloat

	public var projectedValue: Self { self }

	public init(wrappedValue: S) {
		self.init(wrappedValue, by: .zero)
	}

	public init(wrappedValue: S, by amount: CGFloat) {
		self.init(wrappedValue, by: amount)
	}

	/// Creates a wrapper around `wrappedValue` with an initial inset amount.
	/// - Parameters:
	///   - wrappedValue: The underlying insettable shape.
	///   - amount: Initial inset amount.
	public init(_ wrappedValue: S, by amount: CGFloat = .zero) {
		self.wrappedValue = wrappedValue
		self.insetAmount = amount
	}
	
	/// Returns the path of the wrapped shape after applying the current inset.
	public func path(in rect: CGRect) -> Path {
		wrappedValue
			.inset(by: insetAmount)
			.path(in: rect)
	}
	
	/// Returns a copy with the inset amount increased by `amount`.
	public nonisolated func inset(by amount: CGFloat) -> InsettedShape {
		updating { s in
			s.insetAmount += amount
		}
	}
}

// MARK: Optional

/// A `Shape` that conditionally renders another shape.
///
/// When `content` is `nil`, the resulting path is empty.
public struct OptionalShape<Wrapped: Shape>: Shape {
	public let content: Wrapped?
	
	/// Creates an optional shape.
	/// - Parameter content: The wrapped shape, or `nil`.
	public init(_ content: Wrapped?) {
		self.content = content
	}
	
	/// Returns the wrapped shape’s path, or an empty path when `content` is `nil`.
	public func path(in rect: CGRect) -> Path {
		content?.path(in: rect) ?? Path()
	}
}

extension OptionalShape: InsettableShape where Wrapped: InsettableShape {
	public nonisolated func inset(by amount: CGFloat) -> InsettedShape<OptionalShape<Wrapped>> {
		InsettedShape(self, by: amount)
	}
}

// MARK: Empty

/// A `Shape` whose path is always empty.
/// - Note: This is intentionally named like SwiftUI’s concept of an “empty shape”,
///   but scoped to this module.
public struct EmptyShape: Shape {
	public func path(in rect: CGRect) -> Path { Path() }
}

// MARK: Either

/// A `Shape` that holds one of two possible shape types.
///
/// This is primarily used by `ShapeBuilder` to support `if/else` and `switch`.
public enum EitherShape<S1: Shape, S2: Shape>: Shape {
	case first(S1)
	case second(S2)

	/// Returns the path of the stored case.
	public func path(in rect: CGRect) -> Path {
		switch self {
		case .first(let first): first.path(in: rect)
		case .second(let second): second.path(in: rect)
		}
	}
}

extension EitherShape: InsettableShape where S1: InsettableShape, S2: InsettableShape {
	public nonisolated func inset(
		by amount: CGFloat
	) -> InsettedShape<EitherShape<S1, S2>> {
		InsettedShape(self, by: amount)
	}
}

// MARK: Multi Shape

/// A compile-time-sized collection of shapes combined into a single `Path`.
///
/// `MultiShape` stores its children as a variadic generic tuple `(repeat each P)`.
/// This makes it fast and type-safe, but it also means it cannot be built from a
/// runtime-sized array.
///
/// ```swift
/// let s = MultiShape(Circle(), Rectangle(), Capsule())
/// ```
public struct MultiShape<each P: Shape>: Shape, Updatable {
	public let shapes: (repeat each P)
	
	/// Creates a `MultiShape` from a fixed list of shapes.
	public init(_ shapes: repeat each P) {
		self.shapes = (repeat each shapes)
	}
	
	/// Returns a single path made by appending each child shape’s path.
	public func path(in rect: CGRect) -> Path {
		var path: Path = .init()
		/// Initial way to write this expression
		/// `_ = (repeat (path.addPath((each shapes).path(in: rect))))`
		repeat (path.addPath((each shapes).path(in: rect)))
		return path
	}
}

extension MultiShape: InsettableShape where repeat each P: InsettableShape {
	public nonisolated func inset(by amount: CGFloat) -> InsettedShape<Self> {
		InsettedShape(self, by: amount)
	}
}

// MARK: Array-backed Multi Shape

/// A runtime-sized collection of shapes combined into a single `Path`.
///
/// Use this when you only have an array of shapes
/// (for example, the output of a `for` loop inside `ShapeBuilder`).
public struct MultiShapeArray<S: Shape>: Shape, Updatable {
	public let shapes: [S]

	/// Creates an array-backed multi-shape.
	/// - Parameter shapes: Shapes to combine, in order.
	public init(_ shapes: [S]) {
		self.shapes = shapes
	}

	/// Returns a single path made by appending each child shape’s path.
	public func path(in rect: CGRect) -> Path {
		var path: Path = .init()
		for shape in shapes {
			path.addPath(shape.path(in: rect))
		}
		return path
	}
}

extension MultiShapeArray: InsettableShape where S: InsettableShape {
	public nonisolated func inset(by amount: CGFloat) -> InsettedShape<Self> {
		InsettedShape(self, by: amount)
	}
}

// MARK: - Builder

/// A result builder that combines multiple `Shape` statements into a single `Shape`.
///
/// ## This builder supports
/// - Plain blocks (multiple shape statements)
/// - `if`, `if/else`, and `switch`
/// - `for` loops (via an array-backed shape)
/// - Availability checks (`if #available`)
@resultBuilder
public struct ShapeBuilder {
	
	// MARK: 1 - Combine components from a block
	
	/// Builds an empty shape block.
	public static func buildBlock() -> EmptyShape { EmptyShape() }
	
	/// Builds a single-shape block.
	public static func buildBlock<C0: Shape>(_ c0: C0) -> C0 { c0 }
	
	/// Builds a multi-shape block from a fixed list of shapes.
	public static func buildBlock<each P: Shape>(
		_ shapes: repeat each P
	) -> MultiShape<repeat each P> {
		MultiShape(repeat each shapes)
	}
	
	// MARK: 2 - Lift an expression into Component
	
	/// Lifts a `Shape` expression into the builder.
	public static func buildExpression<S: Shape>(_ expression: S) -> S { expression }
	
	// MARK: 3 - Handle `if` without `else`
	
	/// Supports `if` without `else` by wrapping an optional shape.
	public static func buildOptional<S: Shape>(_ os: S?) -> OptionalShape<S> { OptionalShape(os) }
	
	// MARK: 4 - Handle `if/else` and `switch`
	
	/// Supports `if/else` and `switch` by selecting the first branch.
	public static func buildEither<S1: Shape, S2: Shape>(first: S1) -> EitherShape<S1, S2> {
		.first(first)
	}
	/// Supports `if/else` and `switch` by selecting the second branch.
	public static func buildEither<S1: Shape, S2: Shape>(second: S2) -> EitherShape<S1, S2> {
		.second(second)
	}
	/*
	public static func buildEither<First: InsettableShape, Second: InsettableShape>(
		first: First
	) -> EitherShape<First, Second> {
		.first(first)
	}
	public static func buildEither<First: InsettableShape, Second: InsettableShape>(
		second: Second
	) -> EitherShape<First, Second> {
		.second(second)
	}
	public static func buildEither<First: InsettableShape, Second: Shape>(
		first: First
	) -> EitherShape<First, Second> {
		.first(first)
	}
	public static func buildEither<First: Shape, Second: InsettableShape>(
		second: Second
	) -> EitherShape<First, Second> {
		.second(second)
	}
	*/
	
	// MARK: 5 - Handle `for`..`in`
	
	/// Supports `for` loops by combining an array of shapes.
	public static func buildArray<S: Shape>(_ ss: [S]) -> MultiShapeArray<S> { MultiShapeArray(ss) }
	
	// MARK: 6 - Handle `if #available(...) { ... }` in a builder context
	
	/// Type-erases shapes across availability boundaries (`if #available`).
	public static func buildLimitedAvailability(_ s: some Shape) -> AnyShape { AnyShape(s) }
	
	// MARK: 7 - Optionally post-process the final Component into a different return type
	
	/// Optionally post-processes the final component.
	public static func buildFinalResult<S: Shape>(_ component: S) -> S { component }
	
	// MARK: 8 - Alternative to `buildBlock` for scaling to “many statements” efficiently
	
	/// Starts an incremental build for large blocks.
	public static func buildPartialBlock<C0: Shape>(first: C0) -> C0 { first }

	/// Appends a shape to an incremental build.
	public static func buildPartialBlock<Acc: Shape, Next: Shape>(
		accumulated: Acc,
		next: Next
	) -> MultiShape<Acc, Next> {
		MultiShape(accumulated, next)
	}

	/// Appends a shape to an incremental build, flattening the tuple pack.
	public static func buildPartialBlock<each P: Shape, Next: Shape>(
		accumulated: MultiShape<repeat each P>,
		next: Next
	) -> MultiShape<repeat each P, Next> {
		MultiShape(repeat each accumulated.shapes, next)
	}
}

// MARK: - Preview

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
		Ellipse()
			.inset(by: 20)
	}
}

#Preview("Shape Test") {
	Test()
}
#endif
