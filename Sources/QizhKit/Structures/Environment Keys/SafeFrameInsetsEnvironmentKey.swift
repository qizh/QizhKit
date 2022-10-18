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
	
	#if DEBUG
	public func simulateSafeFrameInsets(
		top: CGFloat = NavigationBarDimension.safeFrameTop,
		bottom: CGFloat = NavigationBarDimension.safeFrameBottom
	) -> some View {
		transformEnvironment(\.safeFrameInsets) { insets in
			insets.top = top
			insets.bottom = bottom
		}
	}
	#endif
}

// MARK: Provide

public struct SafeFrameEnvironmentProvider: ViewModifier {
	@State private var insets: EdgeInsets = SafeFrameInsetsKey.defaultValue
	
	public func body(content: Content) -> some View {
		content
			.background {
				GeometryReader { geometry -> Color in
					let current = geometry.safeAreaInsets
					if insets.equals(current, precision: .two) != true {
						execute { self.insets = current }
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
