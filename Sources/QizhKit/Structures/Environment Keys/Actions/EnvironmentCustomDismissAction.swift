//
//  EnvironmentCustomDismissAction.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 21.08.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct CustomDismissActionKey: EnvironmentKey {
	public static let defaultValue: CustomEnvironmentAction = .doNothing
}

extension EnvironmentValues {
	public internal(set) var customDismiss: CustomEnvironmentAction {
		get { self[CustomDismissActionKey.self] }
		set { self[CustomDismissActionKey.self] = newValue }
	}
}

extension View {
	public func dismissable(calling callback: @escaping @Sendable @MainActor () -> Void) -> some View {
		environment(\.customDismiss, .init(callback))
	}
	
	public func dismissable(toggling toggle: Binding<Bool>) -> some View {
		environment(
			\.customDismiss,
			CustomEnvironmentAction {
				toggle.wrappedValue = false
			}
		)
	}
	
	public func dismissable <Value> (
		resetting optional: Binding<Value?>
	) -> some View where Value: Sendable {
		environment(
			\.customDismiss,
			CustomEnvironmentAction {
				optional.wrappedValue = .none
			}
		)
	}
	
	public func dismissable <Value> (
		setting value: Value,
		for property: Binding<Value>
	) -> some View where Value: Sendable {
		environment(
			\.customDismiss,
			CustomEnvironmentAction {
				property.wrappedValue = value
			}
		)
	}
}
