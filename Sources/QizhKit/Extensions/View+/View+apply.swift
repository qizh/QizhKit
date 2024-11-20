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
	@inlinable public func apply <V: View, each P> (
		@ViewBuilder _ transform: (Self, repeat each P) -> V,
		_ parameters: repeat each P
	) -> some View {
		transform(self, repeat each parameters)
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
