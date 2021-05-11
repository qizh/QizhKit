//
//  EnvironmentKey+safeFrameInsets.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 16.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct SafeFrameInsetsKey: EnvironmentKey {
	public static let defaultValue: UIEdgeInsets = SafeFrame.currentInsets
}

public extension EnvironmentValues {
	var safeFrameInsets: UIEdgeInsets {
		get { self[SafeFrameInsetsKey.self] }
		set { self[SafeFrameInsetsKey.self] = newValue }
	}
}

public extension View {
	func safeFrameTop(_ value: CGFloat) -> some View {
		transformEnvironment(\.safeFrameInsets) { safeFrameInsets in
			safeFrameInsets.top = value
		}
	}
	
	func safeFrameBottom(_ value: CGFloat) -> some View {
		transformEnvironment(\.safeFrameInsets) { safeFrameInsets in
			safeFrameInsets.bottom = value
		}
	}
	
	#if DEBUG
	func simulateSafeFrameInsets(
		top: CGFloat = 44,
		bottom: CGFloat = 34
	) -> some View {
		transformEnvironment(\.safeFrameInsets) { insets in
			insets.top = top
			insets.bottom = bottom
		}
	}
	#endif
}
