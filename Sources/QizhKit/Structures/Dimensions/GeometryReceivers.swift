//
//  GeometryReceivers.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Preference Keys

public struct WidthPreferenceKey: PreferenceKey {
	public static var defaultValue: CGFloat = .zero
	public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}

public struct HeightPreferenceKey: PreferenceKey {
	public static var defaultValue: CGFloat = .zero
	public static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		value = nextValue()
	}
}

public struct SafeAreaInsetsPreferenceKey: PreferenceKey {
	public static var defaultValue: EdgeInsets = .zero
	public static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
		value = nextValue()
	}
}

// MARK: Width Modifiers

public struct WidthReaderModifier: ViewModifier {
	public typealias Callback = (_ width: CGFloat) -> Void
	private var receive: Callback?
	@Binding private var width: CGFloat
	
	public init(receive: @escaping Callback) {
		self.receive = receive
		self._width = .constant(.zero)
	}
	
	public init(width: Binding<CGFloat>) {
		self.receive = nil
		self._width = width
	}
	
	public func body(content: Content) -> some View {
		content
//			.preference(key: WidthPreferenceKey.self, value: .zero)
			.background(
				GeometryReader { geometry in
					Color.almostClear
						.transformPreference(WidthPreferenceKey.self) { $0 = geometry.size.width }
						.onPreferenceChange(
							WidthPreferenceKey.self,
							perform: self.receive ?? { self.width = $0 }
						)
				}
			)
	}
}

// MARK: Height Modifiers

public struct HeightBindingModifier: ViewModifier {
	@Binding public var height: CGFloat
	
	public init(_ height: Binding<CGFloat>) {
		self._height = height
	}
	
	public func body(content: Content) -> some View {
		content
			.background(
				GeometryReader { geometry in
					Color.almostClear
						.transformPreference(HeightPreferenceKey.self) { $0 = geometry.size.height }
						.onPreferenceChange(HeightPreferenceKey.self) {
							if height != $0 {
								height = $0
							}
						}
				}
			)
	}
}

public struct HeightCallbackModifier: ViewModifier {
	public typealias Callback = (_ width: CGFloat) -> Void
	public let receive: Callback
	
	public init(_ receive: @escaping Callback) {
		self.receive = receive
	}
	
	public func body(content: Content) -> some View {
		content
			.background(
				GeometryReader { geometry in
					Color.almostClear
						.transformPreference(HeightPreferenceKey.self) { $0 = geometry.size.height }
						.onPreferenceChange(HeightPreferenceKey.self, perform: self.receive )
				}
		)
	}
}

// MARK: Safe Area Modifiers

public struct SafeAreaInsetsBindingModifier: ViewModifier {
	@Binding public var insets: EdgeInsets?
	
	public init(_ insets: Binding<EdgeInsets?>) {
		self._insets = insets
	}
	
	public func body(content: Content) -> some View {
		content.background(GeometryReader(content: read))
	}
	
	private func read(_ geometry: GeometryProxy) -> some View {
		Color.almostClear
		.transformPreference(SafeAreaInsetsPreferenceKey.self) { $0 = geometry.safeAreaInsets }
		 .onPreferenceChange(SafeAreaInsetsPreferenceKey.self) { self.insets = $0 }
	}
}

public struct SafeAreaInsetsCallbackModifier: ViewModifier {
	public typealias Callback = (_ insets: EdgeInsets) -> Void
	public let receive: Callback
	
	public init(_ receive: @escaping Callback) {
		self.receive = receive
	}
	
	public func body(content: Content) -> some View {
		content.background(GeometryReader(content: read))
	}
	
	private func read(_ geometry: GeometryProxy) -> some View {
		Color.almostClear
		.transformPreference(SafeAreaInsetsPreferenceKey.self) { $0 = geometry.safeAreaInsets }
		 .onPreferenceChange(SafeAreaInsetsPreferenceKey.self, perform: self.receive)
	}
}

// MARK: View extension

public extension View {
	
	// MARK: > Width
	
	@inlinable func receiveWidth(
		_ receive: @escaping WidthReaderModifier.Callback
	) -> ModifiedContent<Self, WidthReaderModifier> {
		modifier(WidthReaderModifier(receive: receive))
	}
	
	@inlinable func receiveWidth(
		_ width: Binding<CGFloat>
	) -> ModifiedContent<Self, WidthReaderModifier> {
		modifier(WidthReaderModifier(width: width))
	}
	
	// MARK: > Height
	
	@inlinable func receiveHeight(
		_ receive: @escaping HeightCallbackModifier.Callback
	) -> ModifiedContent<Self, HeightCallbackModifier> {
		modifier(HeightCallbackModifier(receive))
	}
	
	@inlinable func receiveHeight(
		_ height: Binding<CGFloat>
	) -> ModifiedContent<Self, HeightBindingModifier> {
		modifier(HeightBindingModifier(height))
	}
	
	// MARK: > Safe Area Insets
	
	@inlinable func receiveSafeAreaInsets(
		_ receive: @escaping SafeAreaInsetsCallbackModifier.Callback
	) -> ModifiedContent<Self, SafeAreaInsetsCallbackModifier> {
		modifier(SafeAreaInsetsCallbackModifier(receive))
	}
	
	@inlinable func receiveSafeAreaInsets(
		_ insets: Binding<EdgeInsets>
	) -> ModifiedContent<Self, SafeAreaInsetsBindingModifier> {
		modifier(SafeAreaInsetsBindingModifier(insets.optional(default: .zero)))
	}
	
	@inlinable func receiveSafeAreaInsets(
		_ insets: Binding<EdgeInsets?>
	) -> ModifiedContent<Self, SafeAreaInsetsBindingModifier> {
		modifier(SafeAreaInsetsBindingModifier(insets))
	}
}
