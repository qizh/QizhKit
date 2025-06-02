//
//  SwiftUIView.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.06.2025.
//  Copyright © 2025 Bespokely. All rights reserved.
//

public import SwiftUI

// MARK: - Button Style Provider

public struct ButtonPressEnvironmentProvider: ButtonStyle {
	public func makeBody(configuration: Configuration) -> some View {
		configuration.label.environment(\.isPressed, configuration.isPressed)
	}
}

public extension View {
	func buttonStylePressProvider() -> some View {
		buttonStyle(ButtonPressEnvironmentProvider())
	}
}

public struct IsPressedKey: EnvironmentKey {
	public static let defaultValue: Bool = false
}

public extension EnvironmentValues {
	var isPressed: Bool {
		get { self[IsPressedKey.self] }
		set { self[IsPressedKey.self] = newValue }
	}
}

// MARK: - Button Sensory Feedback Modifier

public struct ButtonSensoryFeedbackModifier: ViewModifier {
	fileprivate let pressFeedback: SensoryFeedback?
	fileprivate let releaseFeedback: SensoryFeedback?
	
	@Environment(\.isPressed) fileprivate var isPressed
	@Environment(\.isEnabled) fileprivate var isEnabled
	
	public init(
		press pressFeedback: SensoryFeedback?,
		release releaseFeedback: SensoryFeedback?
	) {
		self.pressFeedback = pressFeedback
		self.releaseFeedback = releaseFeedback
	}
	
	public func body(content: Content) -> some View {
		content.sensoryFeedback(trigger: isPressed) { _, newValue in
			if isEnabled {
				if newValue {
					pressFeedback
				} else {
					releaseFeedback
				}
			} else {
				.none
			}
		}
	}
}

extension View {
	/// Should go before ``buttonStylePressProvider()``, not required for card buttons
	public func sensoryFeedbackOn(
		press pressedFeedback: SensoryFeedback? = .impact(weight: .light),
		release releaseFeedback: SensoryFeedback? = .impact(weight: .medium)
	) -> some View {
		self.modifier(
			ButtonSensoryFeedbackModifier(
				press: pressedFeedback,
				release: releaseFeedback
			)
		)
	}
}
