//
//  View+onAppear.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Optional View Modifier

extension View {
	@_disfavoredOverload
	@ViewBuilder
	public func modifier <M: ViewModifier> (_ modifier: M?) -> some View {
		if let modifier {
			self.modifier(modifier)
		} else {
			self
		}
	}
}

// MARK: On Appear

extension View {
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
