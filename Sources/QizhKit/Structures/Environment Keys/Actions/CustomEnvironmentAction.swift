//
//  CustomEnvironmentAction.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.01.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Empty

public struct CustomEnvironmentAction {
	private let action: () -> Void
	
	internal init(_ action: @escaping () -> Void) {
		self.action = action
	}
	
	public func callAsFunction() {
		action()
	}
}

extension CustomEnvironmentAction {
	public static var doNothing: CustomEnvironmentAction {
		.init { }
	}
	
	public static func toggle(_ binding: Binding<Bool>) -> Self {
		.init {
			binding.wrappedValue = !binding.wrappedValue
		}
	}
	
	public static func reset<T>(_ binding: Binding<T?>) -> Self {
		.init {
			binding.wrappedValue = .none
		}
	}
	
	public static func assign<T>(_ value: T, to binding: Binding<T>) -> Self {
		.init {
			binding.wrappedValue = value
		}
	}
}

// MARK: Bool

public struct CustomEnvironmentBoolAction {
	public let action: (Bool) -> Void
	
	public init(action: @escaping (Bool) -> Void) {
		self.action = action
	}
	
	public func callAsFunction(_ value: Bool) {
		action(value)
	}
}

extension CustomEnvironmentBoolAction {
	public static var doNothing: CustomEnvironmentBoolAction {
		.init { _ in }
	}
}
