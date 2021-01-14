//
//  View+onAppear.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public enum IOSVersion: EasyCaseComparable {
	case iOS13
	case iOS14
}

public extension View {
	@inlinable
	func modifier <M: ViewModifier> (_ modifier: M?) -> some View {
		   modifier.map(view: self.modifier)
		?? self
	}
	
	@inlinable
	func apply <Transformed: View> (
		@ViewBuilder _ transform: (Self) -> Transformed
	) -> some View {
		transform(self)
	}
	
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
	
	@ViewBuilder
	func apply <Transformed: View, T> (
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
	func apply <Transformed: View> (
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
	func apply <Transformed: View, Fallback: View> (
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
	func apply <Transformed: View> (
		for iOS: IOSVersion,
		_ transform: (Self) -> Transformed
	) -> some View {
		if #available(iOS 14.0, *),
		   iOS.is(.iOS14) {
			transform(self)
		} else {
			self
		}
	}
	
	@inlinable
	@ViewBuilder
	func applyForIOS14 <Transformed: View, Fallback: View> (
		_ transform: (Self) -> Transformed,
		else fallback: (Self) -> Fallback
	) -> some View {
		if #available(iOS 14.0, *) {
			transform(self)
		} else {
			fallback(self)
		}
	}
	
	@inlinable
	@ViewBuilder
	func applyForIOS13 <Transformed: View, Fallback: View> (
		_ transform: (Self) -> Transformed,
		else fallback: (Self) -> Fallback
	) -> some View {
		if #available(iOS 14.0, *) {
			fallback(self)
		} else {
			transform(self)
		}
	}
	
	@inlinable
	func map <T, Modified: View> (
		_ value: T?,
		_ transform: (Self, T) -> Modified
	) -> some View {
		   optionals(self, value).map(view: transform)
		?? self
	}
	
	@inlinable
	func onAppearModifier<Modifier: ViewModifier>(_ modifier: Modifier) -> ModifiedContent<Self, ModifyOnAppear<Modifier>> {
		self.modifier(ModifyOnAppear(modifier))
	}
	
	@inlinable
	func applyOnAppear<Transformed: View>(
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
