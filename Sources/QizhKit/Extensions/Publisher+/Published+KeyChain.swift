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

// MARK: String

extension Published where Value == String {
	public init(
		wrappedValue defaultValue: Value,
		keychainKey key: String,
		keychainGroup: KeychainGroup? = .none
	) {
		if let string = KeyChain.string(for: key, at: keychainGroup) {
			self.init(initialValue: string)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				KeyChain.saveString(value, for: key, at: keychainGroup)
			}
			.store()
	}
}

extension Published where Value == String? {
	public init(
		wrappedValue defaultValue: Value,
		keychainKey key: String,
		keychainGroup: KeychainGroup? = .none
	) {
		if let string = KeyChain.string(for: key, at: keychainGroup) {
			self.init(initialValue: string)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				KeyChain.saveString(value, for: key, at: keychainGroup)
			}
			.store()
	}
}

// MARK: Codable

fileprivate let jsonKeychainPublishedLogger = Logger(subsystem: "Published", category: "Json Keychain")

extension Published {
	public init <Model> (
		wrappedValue defaultValue: Value = .none,
		keychainKey key: String,
		keychainGroup: KeychainGroup? = .none,
		encoder: JSONEncoder = .init(),
		decoder: JSONDecoder = .init()
	) where Model: Codable, Value == Model? {
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
			.store()
	}
}

// MARK: KeyChain values

extension KeyChain {
	
	// MARK: ┣ String
	
	public static func string(
		for key: String,
		at group: KeychainGroup?
	) -> String? {
		let key = key.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let data = KeyChain.data(for: key, at: group),
		   let string = String(data: data, encoding: .utf8) {
			return string
		} else {
			return .none
		}
	}
	
	public static func saveString(
		_ string: String?,
		for key: String,
		at group: KeychainGroup?
	) {
		let key = key.localizedLowercase.replacing(.whitespaces, with: .underline)
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
		let key = key.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let data = KeyChain.data(for: key, at: group) {
			return try decoder.decode(Model.self, from: data)
		} else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No data found for key \(key)"))
		}
	}
	
	public static func model<Model: Decodable>(
		for key: String,
		at group: KeychainGroup?,
		decoder: JSONDecoder
	) throws -> Model? {
		let key = key.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let data = KeyChain.data(for: key, at: group) {
			return try decoder.decode(Model.self, from: data)
		} else {
			return .none
		}
	}
	
	public static func saveModel<Model: Encodable>(
		_ model: Model?,
		for key: String,
		at group: KeychainGroup?,
		encoder: JSONEncoder
	) throws {
		let key = key.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let model {
			let data = try encoder.encode(model)
			KeyChain.save(data, for: key, at: group)
		} else {
			KeyChain.remove(for: key, at: group)
		}
	}
}
