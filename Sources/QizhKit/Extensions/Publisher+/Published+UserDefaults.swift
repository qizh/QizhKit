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

public extension Published {
	init(
		wrappedValue defaultValue: Value,
		key: String,
		store: UserDefaults
	) {
		
		/*
		switch defaultValue {
		case is Bool:
			self.init(initialValue: store.bool(forKey: key) as? Value ?? defaultValue)
		case is Int:
			self.init(initialValue: store.integer(forKey: key) as? Value ?? defaultValue)
		case is Float:
			self.init(initialValue: store.float(forKey: key) as? Value ?? defaultValue)
		case is Double:
			self.init(initialValue: store.double(forKey: key) as? Value ?? defaultValue)
		case is CGFloat:
			self.init(initialValue: store.double(forKey: key) as? Value ?? defaultValue)
		case is String:
			self.init(initialValue: store.string(forKey: key) as? Value ?? defaultValue)
		case is Array<String>:
			self.init(initialValue: store.stringArray(forKey: key) as? Value ?? defaultValue)
		case is Dictionary<String, Any>:
			self.init(initialValue: store.dictionary(forKey: key) as? Value ?? defaultValue)
		case is Array<Any>:
			self.init(initialValue: store.array(forKey: key) as? Value ?? defaultValue)
		default:
			self.init(initialValue: defaultValue)
		}
		*/
		
		self.init(initialValue: store.object(forKey: key) as? Value ?? defaultValue)
		
//		cancellables[key] =
		projectedValue
			.sink { value in
				if let optional = value as? OptionalConvertible,
				   optional.isNotSet {
					store.removeObject(forKey: key)
				} else {
					store.set(value, forKey: key)
				}
				/*
				switch value {
				case let value as Bool: 			store.set(value, forKey: key)
				case let value as Int: 				store.set(value, forKey: key)
				case let value as Float: 			store.set(value, forKey: key)
				case let value as Double: 			store.set(value, forKey: key)
				case let value as CGFloat: 			store.set(value, forKey: key)
				case let value as String: 			store.set(value, forKey: key)
				case let value as [String]: 		store.set(value, forKey: key)
				case let value as [String: Any]: 	store.set(value, forKey: key)
				case let value as [Any]: 			store.set(value, forKey: key)
				default: 							store.set(value, forKey: key)
				}
				*/
			}
			.store(in: &cancellables)
	}
}

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
		
//		cancellables[key] =
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
		
//		cancellables[key] =
		projectedValue
			.sink { value in
				store.set(value.rawValue, forKey: key)
			}
			.store(in: &cancellables)
	}
}

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
		
//		cancellables[key] =
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
