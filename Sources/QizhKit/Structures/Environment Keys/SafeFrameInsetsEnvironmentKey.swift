//
//  EnvironmentKey+safeFrameInsets.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 16.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Key

public struct SafeFrameInsetsKey: EnvironmentKey {
	public static let defaultValue: EdgeInsets = .zero
}

public extension EnvironmentValues {
	var safeFrameInsets: EdgeInsets {
		get { self[SafeFrameInsetsKey.self] }
		set { self[SafeFrameInsetsKey.self] = newValue }
	}
}

// MARK: Set

extension View {
	public func safeFrameTop(_ value: CGFloat) -> some View {
		transformEnvironment(\.safeFrameInsets) { safeFrameInsets in
			safeFrameInsets.top = value
		}
	}
	
	public func safeFrameBottom(_ value: CGFloat) -> some View {
		transformEnvironment(\.safeFrameInsets) { safeFrameInsets in
			safeFrameInsets.bottom = value
		}
	}
}

// MARK: Simulate

#if DEBUG
import DeviceKit

extension View {
	/// Transforms `safeFrameInsets` environment with provided `top` and `bottom` values
	///
	/// - SeeAlso: ``simulateSafeFrameInsets(top:bottom:)`` is doing the same for phone only
	public func simulateSafeFrameInsets(
		top: CGFloat = NavigationBarDimension.safeFrameTop,
		bottom: CGFloat = NavigationBarDimension.safeFrameBottom
	) -> some View {
		transformEnvironment(\.safeFrameInsets) { insets in
			insets.top = top
			insets.bottom = bottom
		}
	}
	
	/// Applies ``simulateSafeFrameInsets(top:bottom:)`` modifier on phone only
	///
	/// Checks for `Device.current.isPhone` from ``DeviceKit`` to detect phones
	@ViewBuilder
	public func simulatePhoneSafeFrameInsets(
		top: CGFloat = NavigationBarDimension.safeFrameTop,
		bottom: CGFloat = NavigationBarDimension.safeFrameBottom
	) -> some View {
		if Device.current.isPhone {
			self.simulateSafeFrameInsets(top: top, bottom: bottom)
		} else {
			self
		}
	}
}
#endif

// MARK: Provide

public struct SafeFrameEnvironmentProvider: ViewModifier {
	@State private var insets: EdgeInsets = SafeFrameInsetsKey.defaultValue
	
	public func body(content: Content) -> some View {
		content
			.background {
				GeometryReader { geometry -> Color in
					let current = geometry.safeAreaInsets
					if insets.equals(current, precision: .two) != true {
						Task { @MainActor in
							self.insets = current
						}
					}
					return Color.clear
				}
			}
			.environment(\.safeFrameInsets, insets)
	}
}

extension View {
	public func provideSafeFrameEnvironment() -> some View {
		modifier(SafeFrameEnvironmentProvider())
	}
}
