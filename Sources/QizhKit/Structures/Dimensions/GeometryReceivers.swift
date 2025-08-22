//
//  GeometryReceivers.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

/*
// MARK: Preference Keys

struct WidthPreferenceKey: PreferenceKey {
	static let defaultValue: CGFloat = .zero
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		// value = nextValue()
	}
}

struct HeightPreferenceKey: PreferenceKey {
	static let defaultValue: CGFloat = .zero
	static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
		// value = nextValue()
	}
}

struct SafeAreaInsetsPreferenceKey: PreferenceKey {
	static let defaultValue: EdgeInsets = .zero
	static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
		// value = nextValue()
	}
}
*/

// MARK: Callbacks

public typealias CGFloatSendableCallback = @Sendable (_ value: CGFloat) -> Void
public typealias EdgeInsetsSendableCallback = @Sendable (_ value: EdgeInsets) -> Void

// MARK: Width Modifiers

fileprivate struct WidthReaderModifier: ViewModifier {
	private var receive: CGFloatSendableCallback?
	@Binding private var width: CGFloat
	
	init(receive: @escaping CGFloatSendableCallback) {
		self.receive = receive
		self._width = .constant(.zero)
	}
	
	init(width: Binding<CGFloat>) {
		self.receive = nil
		self._width = width
	}
	
	func body(content: Content) -> some View {
		content.background {
			GeometryReader { geometry in
				Color.clear.preference(
					key: PreferenceKey.self,
					value: geometry.size.width
				)
			}
		}
		.onPreferenceChange(PreferenceKey.self) { value in
			if let receive {
				receive(value)
			} else {
				#if swift(>=6.1)
				/// Works in Xcode 16.3
				self.width = value
				#else
				/// Works in Xcode 16.2 and lags
				Task { @MainActor in
					self.width = value
				}
				#endif
			}
		}
	}
	
	struct PreferenceKey: SwiftUI.PreferenceKey {
		static var defaultValue: CGFloat { .zero }
		static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
			// value = nextValue()
		}
	}
}

// MARK: Height Modifiers

fileprivate struct HeightBindingModifier: ViewModifier {
	@Binding var height: CGFloat
	
	init(_ height: Binding<CGFloat>) {
		self._height = height
	}
	
	func body(content: Content) -> some View {
		content.background {
			GeometryReader { geometry in
				Color.clear.preference(
					key: PreferenceKey.self,
					value: geometry.size.height
				)
			}
		}
		.onPreferenceChange(PreferenceKey.self) { value in
			#if swift(>=6.1)
			/// Works in Xcode 16.3
			self.height = value
			#else
			/// Works in Xcode 16.2 and lags
			Task { @MainActor in
				self.height = value
			}
			#endif
		}
	}
	
	struct PreferenceKey: SwiftUI.PreferenceKey {
		static var defaultValue: CGFloat { .zero }
		static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
			// value = nextValue()
		}
	}
}

fileprivate struct HeightCallbackModifier: ViewModifier {
	let receive: CGFloatSendableCallback
	
	init(_ receive: @escaping CGFloatSendableCallback) {
		self.receive = receive
	}
	
	func body(content: Content) -> some View {
		content.background {
			GeometryReader { geometry in
				Color.clear.preference(
					key: PreferenceKey.self,
					value: geometry.size.height
				)
			}
		}
		.onPreferenceChange(PreferenceKey.self, perform: receive)
	}
	
	struct PreferenceKey: SwiftUI.PreferenceKey {
		static var defaultValue: CGFloat { .zero }
		static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
			// value = nextValue()
		}
	}
}

// MARK: Safe Area Modifiers

fileprivate struct SafeAreaInsetsBindingModifier: ViewModifier {
	@Binding var insets: EdgeInsets?
	
	init(_ insets: Binding<EdgeInsets?>) {
		self._insets = insets
	}
	
	func body(content: Content) -> some View {
		content.background {
			GeometryReader { geometry in
				Color.clear.preference(
					key: PreferenceKey.self,
					value: geometry.safeAreaInsets
				)
			}
		}
		.onPreferenceChange(PreferenceKey.self) { value in
			#if swift(>=6.1)
			/// Works in Xcode 16.3
			self.insets = value
			#else
			/// Works in Xcode 16.2 and lags
			Task { @MainActor in
				self.insets = value
			}
			#endif
		}
	}
	
	struct PreferenceKey: SwiftUI.PreferenceKey {
		static var defaultValue: EdgeInsets { .zero }
		static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
			// value = nextValue()
		}
	}
}

fileprivate struct SafeAreaInsetsCallbackModifier: ViewModifier {
	let receive: EdgeInsetsSendableCallback
	
	init(_ receive: @escaping EdgeInsetsSendableCallback) {
		self.receive = receive
	}
	
	func body(content: Content) -> some View {
		content.background {
			GeometryReader { geometry in
				Color.clear.preference(
					key: PreferenceKey.self,
					value: geometry.safeAreaInsets
				)
			}
		}
		.onPreferenceChange(PreferenceKey.self, perform: receive)
	}
	
	struct PreferenceKey: SwiftUI.PreferenceKey {
		static var defaultValue: EdgeInsets { .zero }
		static func reduce(value: inout EdgeInsets, nextValue: () -> EdgeInsets) {
			// value = nextValue()
		}
	}
}

// MARK: View extension

extension View {
	
	// MARK: > Width
	
	public func receiveWidth(
		_ receive: @escaping CGFloatSendableCallback
	) -> some View {
		modifier(WidthReaderModifier(receive: receive))
	}
	
	public func receiveWidth(
		_ width: Binding<CGFloat>
	) -> some View {
		modifier(WidthReaderModifier(width: width))
	}
	
	// MARK: > Height
	
	public func receiveHeight(
		_ receive: @escaping CGFloatSendableCallback
	) -> some View {
		modifier(HeightCallbackModifier(receive))
	}
	
	public func receiveHeight(
		_ height: Binding<CGFloat>
	) -> some View {
		modifier(HeightBindingModifier(height))
	}
	
	// MARK: > Safe Area Insets
	
	public func receiveSafeAreaInsets(
		_ receive: @escaping EdgeInsetsSendableCallback
	) -> some View {
		modifier(SafeAreaInsetsCallbackModifier(receive))
	}
	
	public func receiveSafeAreaInsets(
		_ insets: Binding<EdgeInsets>
	) -> some View {
		modifier(SafeAreaInsetsBindingModifier(insets.optional(default: .zero)))
	}
	
	public func receiveSafeAreaInsets(
		_ insets: Binding<EdgeInsets?>
	) -> some View {
		modifier(SafeAreaInsetsBindingModifier(insets))
	}
}
