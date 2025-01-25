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
actor CancellableStore {
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

@MainActor private var cancellables = Set<AnyCancellable>()

// MARK: String

extension Published where Value == String {
	@MainActor public init(
		wrappedValue defaultValue: Value,
		keychainKey: String,
		keychainGroup: KeychainGroup? = .none
	) {
		let key = keychainKey.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let data = KeyChain.data(for: key, at: keychainGroup),
		   let string = String(data: data, encoding: .utf8) {
			self.init(initialValue: string)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				if let data = value.data(using: .utf8) {
					KeyChain.save(data, for: key, at: keychainGroup)
				} else {
					KeyChain.remove(for: key, at: keychainGroup)
				}
			}
			.store(in: &cancellables)
	}
}

extension Published where Value == String? {
	@MainActor public init(
		wrappedValue defaultValue: Value,
		keychainKey: String,
		keychainGroup: KeychainGroup? = .none
	) {
		let key = keychainKey.localizedLowercase.replacing(.whitespaces, with: .underline)
		if let data = KeyChain.data(for: key, at: keychainGroup),
		   let string = String(data: data, encoding: .utf8) {
			self.init(initialValue: string)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				if let value = value,
				   let data = value.data(using: .utf8) {
					KeyChain.save(data, for: key, at: keychainGroup)
				} else {
					KeyChain.remove(for: key, at: keychainGroup)
				}
			}
			.store(in: &cancellables)
	}
}

// MARK: Codable

fileprivate let jsonKeychainPublishedLogger = Logger(subsystem: "Published", category: "Json Keychain")

extension Published {
	@MainActor public init <Model> (
		wrappedValue defaultValue: Value = .none,
		keychainKey: String,
		keychainGroup: KeychainGroup? = .none
	) where Model: Codable, Value == Model? {
		let key = keychainKey.localizedLowercase.replacing(.whitespaces, with: .underline)
		
		if let data = KeyChain.data(for: key, at: keychainGroup) {
			do {
				let model = try JSONDecoder().decode(Model.self, from: data)
				self.init(initialValue: model)
			} catch {
				self.init(initialValue: defaultValue)
			}
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				if let value = value {
					do {
						let data = try JSONEncoder().encode(value)
						KeyChain.save(data, for: key, at: keychainGroup)
					} catch {
						jsonKeychainPublishedLogger.error("Can't encode \(Value.self) to save in KeyChain for `\(key)` key. KeyChain value removed. Error: \(error)")
						KeyChain.remove(for: key, at: keychainGroup)
					}
				} else {
					KeyChain.remove(for: key, at: keychainGroup)
				}
			}
			.store(in: &cancellables)
	}
}
