//
//  Published+UserDefaults.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.01.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Combine

private var cancellables = Set<AnyCancellable>()

// MARK: Key

extension Published {
	@_disfavoredOverload
	public init(
		wrappedValue defaultValue: Value,
		key: String,
		store: UserDefaults
	) {
		self.init(initialValue: store.object(forKey: key) as? Value ?? defaultValue)
		
		projectedValue
			.sink { value in
				if let optional = value as? OptionalConvertible,
				   optional.isNotSet {
					store.removeObject(forKey: key)
				} else {
					store.set(value, forKey: key)
				}
			}
			.store(in: &cancellables)
	}
	
	
	/// - Parameters:
	///   - defaultValue: Optional value
	///   - key: ``UserDefaults`` key
	///   - store: ``UserDefaults``
	public init<Wrapped>(
		wrappedValue defaultValue: Value = .none,
		key: String,
		store: UserDefaults
	) where Value == Optional<Wrapped> {
		if let object = store.object(forKey: key),
		   let typedObject = object as? Wrapped {
			self.init(initialValue: typedObject)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				switch value {
				case .none: 			 store.removeObject(forKey: key)
				case .some(let wrapped): store.set(wrapped, forKey: key)
				}
			}
			.store(in: &cancellables)
	}
}

// MARK: Raw Representable Key

public extension Published
	where Value: RawRepresentable,
		  Value.RawValue == String
{
	init(
		wrappedValue defaultValue: Value,
		representableKey key: String,
		store: UserDefaults
	) {
		let current = store.string(forKey: key) ?? .empty
		let value = Value(rawValue: current) ?? defaultValue
		
		self.init(initialValue: value)
		
		projectedValue
			.sink { value in
				store.set(value.rawValue, forKey: key)
			}
			.store(in: &cancellables)
	}
}

public extension Published
	where Value: RawRepresentable,
		  Value.RawValue == Int
{
	init(
		wrappedValue defaultValue: Value,
		representableKey key: String,
		store: UserDefaults
	) {
		let current = store.integer(forKey: key)
		self.init(initialValue: Value(rawValue: current) ?? defaultValue)
		
		projectedValue
			.sink { value in
				store.set(value.rawValue, forKey: key)
			}
			.store(in: &cancellables)
	}
}

// MARK: Codable

public extension Published
	where Value: Codable
{
	init(
		wrappedValue defaultValue: Value,
		codableKey key: String,
		store: UserDefaults
	) {
		if let data = store.data(forKey: key) {
			do {
				let current = try JSONDecoder().decode(Value.self, from: data)
				self.init(initialValue: current)
			} catch {
				self.init(initialValue: defaultValue)
			}
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				do {
					let data = try JSONEncoder().encode(value)
					store.set(data, forKey: key)
				} catch {
					print("::publisher: Can't encode \(Value.self) to save in UserDefaults for `\(key)` key")
				}
			}
			.store(in: &cancellables)
	}
}
