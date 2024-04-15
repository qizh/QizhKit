//
//  View+onAppear.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: View + apply + Variadic Generics

extension View {
	@inlinable public func apply <Transformed: View> (
		@ViewBuilder _ transform: (Self) -> Transformed
	) -> some View {
		transform(self)
	}
	
	@inlinable public func apply <Transformed: View, each Parameter> (
		@ViewBuilder _ transform: (Self, repeat each Parameter) -> Transformed,
		_ parameters: repeat each Parameter
	) -> some View {
		transform(self, repeat each parameters)
	}
}

// MARK: Optional View Modifier

extension View {
	@ViewBuilder
	@_disfavoredOverload
	public func modifier <M: ViewModifier> (_ modifier: M?) -> some View {
		if let modifier {
			self.modifier(modifier)
		} else {
			self
		}
	}
}

// MARK: # old apply

#if swift(<5.9)
public extension View {
	@inlinable
	func apply <Transformed: View, T> (
		@ViewBuilder _ transform: (Self, T) -> Transformed,
		_ argument: T
	) -> some View {
		transform(self, argument)
	}
	
	@inlinable
	func apply <Transformed: View, T1, T2> (
		@ViewBuilder _ transform: (Self, T1, T2) -> Transformed,
		_ argument1: T1,
		_ argument2: T2
	) -> some View {
		transform(self, argument1, argument2)
	}
}
#endif

extension View {
	@ViewBuilder
	public func apply <Transformed: View, T> (
		mapping optional: T?,
		@ViewBuilder _ transform: (Self, T) -> Transformed
	) -> some View {
		if let value = optional {
			transform(self, value)
		} else {
			self
		}
	}
	
	@ViewBuilder
	public func apply <Transformed: View, T1, T2> (
		mapping optional1: T1?,
		    and optional2: T2?,
		@ViewBuilder _ transform: (Self, T1, T2) -> Transformed
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
	public func apply <Transformed: View> (
		when condition: Bool,
		@ViewBuilder _ transform: (Self) -> Transformed
	) -> some View {
		if condition {
			transform(self)
		} else {
			self
		}
	}
	
	@ViewBuilder
	public func apply <Transformed: View, Fallback: View> (
		when condition: Bool,
		   _ transform: (Self) -> Transformed,
		else  fallback: (Self) -> Fallback
	) -> some View {
		if condition {
			transform(self)
		} else {
			fallback(self)
		}
	}
	
	@ViewBuilder
	public func map <T, Modified: View> (
		_ value: T?,
		_ transform: (Self, T) -> Modified
	) -> some View {
		if let value {
			transform(self, value)
		} else {
			self
		}
	}
	
	// MARK: On Appear
	
	@inlinable
	public func onAppearModifier<Modifier: ViewModifier>(_ modifier: Modifier) -> ModifiedContent<Self, ModifyOnAppear<Modifier>> {
		self.modifier(ModifyOnAppear(modifier))
	}
	
	@inlinable
	public func applyOnAppear<Transformed: View>(
		_ transform: (Self) -> Transformed
	) -> ModifiedContent<Self, OnAppearChange<Transformed>> {
		modifier(OnAppearChange(to: transform(self)))
	}
}

public struct OnAppearChange<Other: View>: ViewModifier {
	private let other: Other
	
	@State private var didAppear: Bool = false
	
	public init(to other: Other) {
		self.other = other
	}
	
	@ViewBuilder public func body(content: Content) -> some View {
		if didAppear {
			other
		} else {
			content.onAppear { self.didAppear = true }
		}
	}
}

public struct ModifyOnAppear<Modifier: ViewModifier>: ViewModifier {
	private let modifier: Modifier
	
	@State private var didAppear: Bool = false
	
	public init(_ modifier: Modifier) {
		self.modifier = modifier
	}
	
	@ViewBuilder public func body(content: Content) -> some View {
		if didAppear {
			content.modifier(modifier)
		} else {
			content.onAppear { self.didAppear = true }
		}
	}
}

// MARK: Views generation

public struct Views {
	@inlinable public static func produce <T> (
		using value: T,
		@ViewBuilder _ producer: (T) -> some View
	) -> some View {
		producer(value)
	}
	
	@ViewBuilder
	@inlinable public static func produce <T> (
		when value: T?,
		@ViewBuilder _ producer: (T) -> some View
	) -> some View {
		if let value {
			producer(value)
		}
	}
}

// MARK: Available bug workaround

public struct CallbackViewModifier <Transformed: View>: ViewModifier {
	private let transform: (AnyView) -> Transformed
	
	public init(@ViewBuilder _ transform: @escaping (AnyView) -> Transformed) {
		self.transform = transform
	}
	
	public func body(content: Content) -> some View {
		transform(content.asAnyView())
	}
}

/// Doesn't make any sense since you still need to check for iOS 15 availability
/// in the `transform` closure
/*
extension View {
	@ViewBuilder
	public func applyForIOS15 <Transformed: View, Fallback: View> (
		@ViewBuilder _ transform: @escaping (AnyView) -> Transformed,
		@ViewBuilder else fallback: @escaping (AnyView) -> Fallback
	) -> some View {
		if #available(iOS 15.0, *) {
			self.modifier(CallbackViewModifier(transform))
		} else {
			self.modifier(CallbackViewModifier(fallback))
		}
	}
}
*/
