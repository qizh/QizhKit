//
//  AnyHashableAndSendable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 11.12.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

public protocol HashableAndSendableAdoptable: Hashable, Sendable {
	func hash(into hasher: inout Hasher)
	func isEqual(to other: any HashableAndSendableAdoptable) -> Bool
}

@propertyWrapper
public struct AnyHashableAndSendable: Hashable, Sendable {
	public let wrappedValue: any HashableAndSendableAdoptable
	
	public init<H: Hashable & Sendable>(wrappedValue: H) {
		self.wrappedValue = HashableAndSendable(wrappedValue)
	}
	
	public init<H: Hashable & Sendable>(_ base: H) {
		self.wrappedValue = HashableAndSendable(base)
	}

	public func hash(into hasher: inout Hasher) {
		wrappedValue.hash(into: &hasher)
	}

	public static func ==(lhs: AnyHashableAndSendable, rhs: AnyHashableAndSendable) -> Bool {
		lhs.wrappedValue.isEqual(to: rhs.wrappedValue)
	}
	
	public struct HashableAndSendable<Value: Hashable & Sendable>: HashableAndSendableAdoptable {
		public let value: Value

		public init(_ value: Value) {
			self.value = value
		}

		public func hash(into hasher: inout Hasher) {
			value.hash(into: &hasher)
		}

		public func isEqual(to other: any HashableAndSendableAdoptable) -> Bool {
			if let otherBox = other as? HashableAndSendable<Value> {
				self.value == otherBox.value
			} else {
				false
			}
		}
	}
}
