//
//  Published+UserDefaults.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.01.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Combine
import os.log

/*
// MARK: Cancellable Store

final actor CancellableStore {
	public static let shared = CancellableStore()
	
	private var cancellables = Set<AnyCancellable>()
	
	init() {}
	
	func store(_ cancellable: AnyCancellable) {
		cancellables.insert(cancellable)
	}
	
	func cancelAll() {
		cancellables.removeAll()
	}
}

// MARK: Cancellable + store

extension AnyCancellable {
	func storeInActor(_ actor: CancellableStore) async {
		await actor.store(self)
	}
	
	func storeInSharedActor() {
		Task {
			await CancellableStore.shared.store(self)
		}
	}
}
*/

// @MainActor private var mainActorCncellables = Set<AnyCancellable>()

// MARK: Key

extension Published {
	@_disfavoredOverload
	public init(
		wrappedValue defaultValue: Value,
		key: String,
		store: UserDefaults,
		cancellables: inout Set<AnyCancellable>
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
		store: UserDefaults,
		cancellables: inout Set<AnyCancellable>
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

fileprivate let rawRepresentableLogger = Logger(subsystem: "Published", category: "RawRepresentable in UserDefaults")

extension Published
	where Value: RawRepresentable,
		  Value.RawValue == String
{
	public init(
		wrappedValue defaultValue: Value,
		representableKey key: String,
		store: UserDefaults,
		cancellables: inout Set<AnyCancellable>
	) {
		let current = store.string(forKey: key) ?? .empty
		let value = Value(rawValue: current) ?? defaultValue
		/*
		rawRepresentableLogger.debug("""
			Loging initial value
			┣ for key: \(key)
			┣ in store: \(store)
			┣ or default: \(defaultValue.rawValue)
			┣ store value: \(store.string(forKey: key))
			┗━→ value: \(value.rawValue)
			""")
		*/
		
		self.init(initialValue: value)
		
		projectedValue
			.sink { value in
				store.set(value.rawValue, forKey: key)
			}
			.store(in: &cancellables)
	}
}

extension Published
	where Value: RawRepresentable,
		  Value.RawValue == Int
{
	public init(
		wrappedValue defaultValue: Value,
		representableKey key: String,
		store: UserDefaults,
		cancellables: inout Set<AnyCancellable>
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

fileprivate let codableLogger = Logger(subsystem: "Published", category: "Codable in UserDefaults")

extension Published where Value: Codable {
	public init(
		wrappedValue defaultValue: Value,
		codableKey key: String,
		store: UserDefaults,
		cancellables: inout Set<AnyCancellable>,
		decoder: JSONDecoder = .init(),
		encoder: JSONEncoder = .init()
	) {
		do {
			let current: Value = try store.model(forKey: key, decoder: decoder)
			self.init(initialValue: current)
		} catch {
			codableLogger.warning("Can't decode \(Value.self) from UserDefaults for `\(key)` key.\nInitializing with default value.\nError: \(error)")
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				do {
					try store.saveModel(value, forKey: key, encoder: encoder)
				} catch {
					codableLogger.error("Can't encode \(Value.self) to save in UserDefaults for `\(key)` key.\nError: \(error)")
				}
			}
			.store(in: &cancellables)
	}
}

// MARK: UserDefaults + Model

extension UserDefaults {
	public func model<Model: Decodable>(
		forKey key: String,
		decoder: JSONDecoder = .init()
	) throws -> Model {
		if let data = data(forKey: key) {
			try decoder.decode(Model.self, from: data)
		} else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No data found for key \(key)"))
		}
	}
	
	public func saveModel<Model: Encodable>(
		_ model: Model,
		forKey key: String,
		encoder: JSONEncoder = .init()
	) throws {
		let data = try encoder.encode(model)
		set(data, forKey: key)
	}
}
