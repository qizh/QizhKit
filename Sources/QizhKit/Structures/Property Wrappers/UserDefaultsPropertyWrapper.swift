//
//  UserDefaultsPropertyWrapper.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 26.11.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

/*
import Foundation
import Combine

@available(iOS, deprecated: 14.0, obsoleted: 15.0, message: "Use `AppStorage` instead")
@propertyWrapper public struct UserDefault <Value> {
	private let key: String
	private let defaultValue: Value
	private let virtual: Bool
	
	public init(_ key: String, default defaultValue: Value) {
		self.key = key
		self.defaultValue = defaultValue
		self.virtual = false
	}
	
	public init(virtual value: Value) {
		self.key = .empty
		self.defaultValue = value
		self.virtual = true
	}
	
	public var wrappedValue: Value {
		get {
			virtual
				? defaultValue
				: UserDefaults.standard.object(forKey: key) as? Value ?? defaultValue
		}
		set {
			if !virtual {
				UserDefaults.standard.set(newValue, forKey: key)
			}
		}
	}
}

@available(iOS, deprecated: 14.0, message: "Use `AppStorage` instead")
@propertyWrapper public struct UserDefaultEnum <Value: RawRepresentable> {
	private let key: String
	private let defaultValue: Value
	private let virtual: Bool
	
	public init(_ key: String, default defaultValue: Value) {
		self.key = key
		self.defaultValue = defaultValue
		self.virtual = false
	}
	
	public init(_ key: String, default defaultValue: Value.RawValue) {
		self.key = key
		self.defaultValue = Value(rawValue: defaultValue)
			.forceUnwrap(because: "Provided raw value suppose to be valid")
		self.virtual = false
	}
	
	public init(virtual value: Value) {
		self.key = .empty
		self.defaultValue = value
		self.virtual = true
	}
	
	public var wrappedValue: Value {
		get {
			if virtual {
				return defaultValue
			}
			
			let raw = UserDefaults.standard.object(forKey: key)
			let defaultRaw = defaultValue.rawValue
			var value: Value? = nil
			
			if let number = raw as? NSNumber {
				switch Value.RawValue.self {
				case is Int.Type:
					value = Value(rawValue: number.intValue as? Value.RawValue ?? defaultRaw)
				case is UInt.Type:
					value = Value(rawValue: number.uintValue as? Value.RawValue ?? defaultRaw)
				case is Int8.Type:
					value = Value(rawValue: number.int8Value as? Value.RawValue ?? defaultRaw)
				case is UInt8.Type:
					value = Value(rawValue: number.uint8Value as? Value.RawValue ?? defaultRaw)
				default: ()
				}
			} else {
				value = Value(rawValue: raw as? Value.RawValue ?? defaultRaw)
			}
			
			return value ?? defaultValue
		}
		set {
			if virtual {
				return
			}
			
			let defaults = UserDefaults.standard
			let provided = newValue.rawValue
			
			switch provided {
			case let value as  Int: 	defaults.set(NSNumber(value: value), forKey: key)
			case let value as  Int8: 	defaults.set(NSNumber(value: value), forKey: key)
			case let value as UInt: 	defaults.set(NSNumber(value: value), forKey: key)
			case let value as UInt8: 	defaults.set(NSNumber(value: value), forKey: key)
			default: 					defaults.set(provided, forKey: key)
			}
		}
	}
}

internal protocol RawValueExtractable {
	func extractValue() -> Any
}

internal extension RawValueExtractable where Self: RawRepresentable {
	func extractValue() -> Any {
		rawValue as Any
	}
}

internal func extractRawValue(from subject: Any) -> Any? {
	let mirror = Mirror(reflecting: subject)
	
	guard let displayStyle = mirror.displayStyle,
		  case .enum = displayStyle,
		  let extractable = subject as? RawValueExtractable
	else { return nil }
	
	return extractable.extractValue()
}

@available(iOS, deprecated: 14.0, message: "Use `AppStorage` instead")
@propertyWrapper public struct CodableUserDefault <T: Codable> {
	private let key: String
	private let defaultValue: T
	
	public init(_ key: String, default defaultValue: T) {
		self.key = key
		self.defaultValue = defaultValue
	}
	
	public var wrappedValue: T {
		get {
			if let data = UserDefaults.standard.data(forKey: key),
			   let value = try? JSONDecoder().decode(T.self, from: data) {
				return value
			}
			return defaultValue
		}
		set {
			let data = (try? JSONEncoder().encode(newValue))
					?? (try? JSONEncoder().encode(defaultValue))
			UserDefaults.standard.set(data, forKey: key)
		}
	}
}

@available(iOS, deprecated: 14.0, obsoleted: 15.0, message: "Use `AppStorage` instead")
public extension CodableUserDefault where T: EmptyProvidable {
	init(_ key: String) {
		self.key = key
		self.defaultValue = .empty
	}
}

@available(iOS, deprecated: 14.0, obsoleted: 15.0, message: "Use `AppStorage` instead")
public extension CodableUserDefault where T: WithDefault {
	init(_ key: String) {
		self.key = key
		self.defaultValue = .default
	}
}

@available(iOS, deprecated: 14.0, obsoleted: 15.0, message: "Use `AppStorage` instead")
public extension CodableUserDefault where T: WithUnknown {
	init(_ key: String) {
		self.key = key
		self.defaultValue = .unknown
	}
}

@available(iOS, deprecated: 14.0, obsoleted: 15.0, message: "Use `AppStorage` instead")
@propertyWrapper public struct ResettableUserDefault <Value> {
	private let key: String
	private let defaultValue: Value?
	private var changePublisher: ObservableObjectPublisher?
	private let virtual: Bool
	
	public init(
		_ key: String,
		default defaultValue: Value? = .none
	) {
		self.key = key
		self.defaultValue = defaultValue
		self.virtual = false
	}
	
	public init <Key> (
		_ key: Key,
		default defaultValue: Value? = .none
	)
		where
		Key: RawRepresentable,
		Key.RawValue == String
	{
		self.init(key.rawValue, default: defaultValue)
	}
	
	public init(virtual value: Value) {
		self.key = .empty
		self.defaultValue = value
		self.virtual = true
	}
	
	public var wrappedValue: Value? {
		get {
			if not(virtual),
			   let value = UserDefaults.standard.object(forKey: key) as? Value
			{
				if let possibleEmptyValue = value as? EmptyTestable,
				   possibleEmptyValue.isEmpty
				{
					return defaultValue
				} else {
					return value
				}
			} else {
				return defaultValue
			}
		}
		set {
			guard not(virtual) else { return }
			self.changePublisher?.send()
			if newValue.isSet {
				if let possibleEmptyValue = newValue as? EmptyTestable,
				   possibleEmptyValue.isEmpty
				{
					UserDefaults.standard.removeObject(forKey: key)
				} else {
					UserDefaults.standard.set(newValue, forKey: key)
				}
			} else {
				UserDefaults.standard.removeObject(forKey: key)
			}
		}
	}
	
	public mutating func on(change: ObservableObjectPublisher) {
		self.changePublisher = change
	}
}

@available(iOS, deprecated: 14.0, obsoleted: 15.0, message: "Use `AppStorage` instead")
@propertyWrapper public struct UserDefaultJson <T: Codable> {
	private let key: String
	private let defaultValue: T
	
	public init(_ key: String, default defaultValue: T) {
		self.key = key
		self.defaultValue = defaultValue
	}
	
	public var wrappedValue: T {
		get {
			guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
				return defaultValue
			}
			
			let value = try? JSONDecoder().decode(T.self, from: data)
			return value ?? defaultValue
		}
		set {
			let data = try? JSONEncoder().encode(newValue)
			UserDefaults.standard.set(data, forKey: key)
		}
	}
}
*/
