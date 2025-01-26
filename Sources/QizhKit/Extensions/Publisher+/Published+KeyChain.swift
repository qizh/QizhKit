//
//  Published+KeyChain.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 07.06.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Combine
import os.log

/*
// MARK: Cancellable + Sendable

extension AnyCancellable: @retroactive @unchecked Sendable { }

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
	func storeInActor(_ actor: CancellableStore) {
		Task {
			await actor.store(self)
		}
	}
	
	func storeInSharedActor() {
		Task {
			await CancellableStore.shared.store(self)
		}
	}
}
*/

// @MainActor private var cancellables = Set<AnyCancellable>()

// MARK: String

extension Published where Value == String {
	public init(
		wrappedValue defaultValue: Value,
		keychainKey: String,
		keychainGroup: KeychainGroup? = .none,
		cancellables: inout Set<AnyCancellable>
	) {
		let key = keychainKey.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let string = KeyChain.string(for: key, at: keychainGroup) {
			self.init(initialValue: string)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				KeyChain.saveString(value, for: keychainKey, at: keychainGroup)
			}
			// .storeInSharedActor()
			.store(in: &cancellables)
	}
}

extension Published where Value == String? {
	public init(
		wrappedValue defaultValue: Value,
		keychainKey: String,
		keychainGroup: KeychainGroup? = .none,
		cancellables: inout Set<AnyCancellable>
	) {
		let key = keychainKey.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let string = KeyChain.string(for: key, at: keychainGroup) {
			self.init(initialValue: string)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				KeyChain.saveString(value, for: keychainKey, at: keychainGroup)
			}
			// .storeInSharedActor()
			.store(in: &cancellables)
	}
}

// MARK: Codable

fileprivate let jsonKeychainPublishedLogger = Logger(subsystem: "Published", category: "Json Keychain")

extension Published {
	public init <Model> (
		wrappedValue defaultValue: Value = .none,
		keychainKey: String,
		keychainGroup: KeychainGroup? = .none,
		cancellables: inout Set<AnyCancellable>,
		encoder: JSONEncoder = .init(),
		decoder: JSONDecoder = .init()
	) where Model: Codable, Value == Model? {
		let key = keychainKey.localizedLowercase.replacing(.whitespaces, with: .underline)
		
		do {
			let model: Model = try KeyChain.model(for: key, at: keychainGroup, decoder: decoder)
			self.init(initialValue: model)
		} catch {
			jsonKeychainPublishedLogger.warning("Can't decode \(Value.self) from KeyChain for `\(key)` key.\nInitializing with default value.\nError: \(error)")
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				do {
					try KeyChain.saveModel(value, for: key, at: keychainGroup, encoder: encoder)
				} catch {
					jsonKeychainPublishedLogger.error("Can't encode \(Value.self) to save in KeyChain for `\(key)` key.\nKeyChain value removed.\nError: \(error)")
					KeyChain.remove(for: key, at: keychainGroup)
				}
			}
			// .storeInSharedActor()
			.store(in: &cancellables)
	}
}

// MARK: KeyChain values

extension KeyChain {
	
	// MARK: ┣ String
	
	public static func string(
		for key: String,
		at group: KeychainGroup?
	) -> String? {
		if let data = KeyChain.data(for: key, at: group),
		   let string = String(data: data, encoding: .utf8) {
			string
		} else {
			.none
		}
	}
	
	public static func saveString(
		_ string: String?,
		for key: String,
		at group: KeychainGroup?
	) {
		if let data = string?.data(using: .utf8) {
			KeyChain.save(data, for: key, at: group)
		} else {
			KeyChain.remove(for: key, at: group)
		}
	}
	
	// MARK: ┗ Codable model
	
	public static func model<Model: Decodable>(
		for key: String,
		at group: KeychainGroup?,
		decoder: JSONDecoder
	) throws -> Model {
		if let data = KeyChain.data(for: key, at: group) {
			try decoder.decode(Model.self, from: data)
		} else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No data found for key \(key)"))
		}
	}
	
	public static func model<Model: Decodable>(
		for key: String,
		at group: KeychainGroup?,
		decoder: JSONDecoder
	) throws -> Model? {
		if let data = KeyChain.data(for: key, at: group) {
			try decoder.decode(Model.self, from: data)
		} else {
			.none
		}
	}
	
	public static func saveModel<Model: Encodable>(
		_ model: Model?,
		for key: String,
		at group: KeychainGroup?,
		encoder: JSONEncoder
	) throws {
		if let model {
			let data = try encoder.encode(model)
			KeyChain.save(data, for: key, at: group)
		} else {
			KeyChain.remove(for: key, at: group)
		}
	}
}
