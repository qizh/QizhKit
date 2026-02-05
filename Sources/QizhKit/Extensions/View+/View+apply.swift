//
//  View+onAppear.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: View + apply

extension View {
	@inlinable public func apply <V: View> (
		@ViewBuilder _ transform: (Self) -> V
	) -> some View {
		transform(self)
	}
}

#if swift(>=5.10)

// MARK: > Variadic Generics

extension View {
	/// Applies a transformation to the current view, returning the transformed result.
	/// 
	/// Use this helper to make view modifier chains more expressive by
	/// grouping multiple modifiers or conditional logic inside a single closure.
	/// The closure receives `self` (the current view) and must return a new view.
	/// ## Example
	/// ```swift
	/// VStack {
	///     Text("Title")
	/// }
	/// .apply { view in
	///     view
	///         .padding()
	///         .background(.blue.opacity(0.1))
	/// }
	/// ```
	/// - Parameter transform: A closure that takes the current view as input and
	///   returns a transformed view. Use `@ViewBuilder` to compose multiple view
	///   modifiers and layout containers within the closure.
	/// - Returns: The result of applying `transform` to the current view.
	@inlinable public func apply <V: View, each P> (
		@ViewBuilder _ transform: (Self, repeat each P) -> V,
		_ parameters: repeat each P
	) -> some View {
		transform(self, repeat each parameters)
	}
	
	/// Conditionally applies a transformation to the current view,
	/// passing additional parameters.
	///
	/// Use this overload when you want to modify a view only if a Boolean condition
	/// is `true`, while also supplying one or more extra parameters to the transformation.
	/// The original view is returned unchanged when the condition is `false`.
	/// ## Example
	/// ```swift
	/// VStack {
	///     Text("Hello")
	/// }
	/// .apply(
	/// 	when: isHighlighted, Color.yellow.opacity(0.2), 12
	/// ) { view, color, radius in
	///     view
	///         .padding()
	///         .background(color)
	///         .clipShape(RoundedRectangle(cornerRadius: radius))
	/// }
	/// ```
	/// - Parameters:
	///   - condition: A Boolean value that determines
	///     whether the transformation is applied.
	///   - transform: A closure that takes the current view (`self`)
	///     followed by the supplied parameters and returns a transformed view.
	///     Use `@ViewBuilder` to compose multiple modifiers and layout containers.
	///   - parameters: One or more additional values to pass through
	///     to the `transform` closure.
	/// - Returns: The transformed view when `condition` is `true`;
	///   otherwise, the original view.
	@ViewBuilder
	public func apply<V: View, each P> (
		when condition: Bool,
		@ViewBuilder _ transform: (Self, repeat each P) -> V,
		_ parameters: repeat each P
	) -> some View {
		if condition {
			transform(self, repeat each parameters)
		} else {
			self
		}
	}
}

#else

// MARK: > Outdated

extension View {
	@inlinable public func apply <T> (
		@ViewBuilder _ transform: (Self, T) -> some View,
		_ argument: T
	) -> some View {
		transform(self, argument)
	}
	
	@inlinable public func apply <T1, T2> (
		@ViewBuilder _ transform: (Self, T1, T2) -> some View,
		_ argument1: T1,
		_ argument2: T2
	) -> some View {
		transform(self, argument1, argument2)
	}
	
	@inlinable public func apply <T1, T2, T3> (
		@ViewBuilder _ transform: (Self, T1, T2, T3) -> some View,
		_ argument1: T1,
		_ argument2: T2,
		_ argument3: T3
	) -> some View {
		transform(self, argument1, argument2, argument3)
	}
}

#endif

// MARK: View + apply + other

extension View {
	@ViewBuilder
	public func apply <T> (
		when optional: T?,
		@ViewBuilder _ transform: (Self, T) -> some View
	) -> some View {
		if let optional {
			transform(self, optional)
		} else {
			self
		}
	}

	@ViewBuilder
	public func apply <T> (
		when optional: T?,
		_ transform: (Self, T) -> some View,
		else fallback: (Self) -> some View
	) -> some View {
		if let optional {
			transform(self, optional)
		} else {
			fallback(self)
		}
	}
	
	@ViewBuilder
	public func apply <T1, T2> (
		when optional1: T1?,
		 and optional2: T2?,
		@ViewBuilder _ transform: (Self, T1, T2) -> some View
	) -> some View {
		if let value1 = optional1,
		   let value2 = optional2
		{
			transform(self, value1, value2)
		} else {
			self
		}
	}
	
	/// Conditionally transforms the current view when both optional values are non-`nil`.
	///
	/// Use this overload to apply a transformation that depends on two optional inputs.
	/// If both `optional1` and `optional2` contain values, the `transform` closure is
	/// invoked with `self` and the unwrapped values, and its result is returned.
	/// If either optional is `nil`, the original view (`self`) is returned unchanged.
	/// - Parameters:
	///   - optional1: The first optional value to unwrap.
	///   - optional2: The second optional value to unwrap.
	///   - transform: A closure that takes the current view and the two unwrapped values,
	///     returning a new view. The closure is only executed when both optionals are
	///     non-nil.
	/// - Returns: The transformed view when both optionals are non-nil;
	///   otherwise, the original view.
	/// - Note: Prefer this method when you need both values to proceed;
	///   if you also need a fallback when either value is missing,
	///   use the overload that includes an `else` fallback closure.
	@ViewBuilder
	public func apply <T1, T2> (
		when optional1: T1?,
		 and optional2: T2?,
		@ViewBuilder _ transform: (Self, T1, T2) -> some View,
		else fallback: (Self) -> some View
	) -> some View {
		if let optional1, let optional2 {
			transform(self, optional1, optional2)
		} else {
			fallback(self)
		}
	}
	
	@ViewBuilder
	public func apply(
		when condition: Bool,
		@ViewBuilder _ transform: (Self) -> some View
	) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
	
	@ViewBuilder
	public func apply(
		when condition: Bool,
		   _ transform: (Self) -> some View,
		else  fallback: (Self) -> some View
	) -> some View {
		if condition {
			transform(self)
		} else {
			fallback(self)
		}
	}
	
	@ViewBuilder
	public func map <T> (
		_ value: T?,
		_ transform: (Self, T) -> some View
	) -> some View {
		if let value {
			transform(self, value)
		} else {
			self
		}
	}
}

// MARK: > Deprecated

extension View {
	@available(*, deprecated, renamed: "apply(when:_:)", message: "Renamed `mapping` parameter to `when`")
	@ViewBuilder
	public func apply <T> (
		mapping optional: T?,
		@ViewBuilder _ transform: (Self, T) -> some View
	) -> some View {
		if let value = optional {
			transform(self, value)
		} else {
			self
		}
	}
	
	@available(*, deprecated, renamed: "apply(when:and:_:)", message: "Renamed `mapping` parameter to `when`")
	@ViewBuilder
	public func apply <T1, T2> (
		mapping optional1: T1?,
			and optional2: T2?,
		@ViewBuilder _ transform: (Self, T1, T2) -> some View
	) -> some View {
		if let value1 = optional1,
		   let value2 = optional2
		{
			transform(self, value1, value2)
		} else {
			self
		}
	}
}

// MARK: Text + apply

extension Text {
	@inlinable public func apply(
		_ transform: (Text) -> Text
	) -> Text {
		transform(self)
	}
}

#if swift(>=5.10)

// MARK: > Variadic Generics

extension Text {
	public func apply <each P> (
		_ transform: (Text, repeat each P) -> Text,
		_ parameters: repeat each P
	) -> Text {
		transform(self, repeat each parameters)
	}
}

#else

// MARK: > Outdated

extension Text {
	@inlinable public func apply<T>(
		_ transform: (Text, T) -> Text,
		_ argument: T
	) -> Text {
		transform(self, argument)
	}
	
	@inlinable public func apply<T1, T2>(
		_ transform: (Text, T1, T2) -> Text,
		_ argument1: T1,
		_ argument2: T2
	) -> Text {
		transform(self, argument1, argument2)
	}
	
	@inlinable public func apply<T1, T2, T3>(
		_ transform: (Text, T1, T2, T3) -> Text,
		_ argument1: T1,
		_ argument2: T2,
		_ argument3: T3
	) -> Text {
		transform(self, argument1, argument2, argument3)
	}
}

#endif

// MARK: > Test

/*
fileprivate func t0(text: Text) -> Text { text }
fileprivate func t1(text: Text, int: Int) -> Text { text }
fileprivate func t2(text: Text, x: Int, y: String) -> Text { text }
fileprivate let t = Text(String(""))
	.apply(t0)
	.apply(t1, 12)
	.apply(t2, 13, "")

fileprivate func v0(view: some View) -> some View { view }
fileprivate func v1(view: some View, x: Int) -> some View { view }
fileprivate func v2(view: some View, x: Int, y: String) -> some View { view }
fileprivate func testApplyView() -> some View {
	HStack {
		Color.pink
	}
	.apply { view in
		VStack {
			view
		}
	}
	.apply(v0)
	.apply(v1, 12)
	.apply(v2, 13, "")
}
*/
