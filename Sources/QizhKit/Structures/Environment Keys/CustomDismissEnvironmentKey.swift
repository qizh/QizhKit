//
//  CustomDismissEnvironmentKey.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 21.08.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct CustomDismissAction: EmptyProvidable {
	private let callback: () -> Void
	
	internal init(_ callback: @escaping () -> Void) {
		self.callback = callback
	}
	
	public func callAsFunction() {
		callback()
	}
	
	public static let empty: CustomDismissAction = .init({})
}

public struct CustomDismissActionKey: EnvironmentKey {
	public static var defaultValue: CustomDismissAction = .empty
}

extension EnvironmentValues {
	public internal(set) var customDismiss: CustomDismissAction {
		get { self[CustomDismissActionKey.self] }
		set { self[CustomDismissActionKey.self] = newValue }
	}
}

extension View {
	public func dismissable(calling callback: @escaping () -> Void) -> some View {
		environment(\.customDismiss, .init(callback))
	}
	
	public func dismissable(toggling toggle: Binding<Bool>) -> some View {
		environment(
			\.customDismiss,
			CustomDismissAction {
				toggle.wrappedValue = false
			}
		)
	}
	
	public func dismissable <Value> (resetting optional: Binding<Value?>) -> some View {
		environment(
			\.customDismiss,
			CustomDismissAction {
				optional.wrappedValue = .none
			}
		)
	}
	
	public func dismissable <Value> (
		setting value: Value,
		for property: Binding<Value>
	) -> some View {
		environment(
			\.customDismiss,
			CustomDismissAction {
				property.wrappedValue = value
			}
		)
	}
}
