//
//  KeyChain.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 07.06.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Security

public struct KeychainGroup: RawRepresentable, ExpressibleByStringLiteral, Sendable {
	public let rawValue: String
	
	public init(rawValue: String) {
		self.rawValue = rawValue
	}
	
	@inlinable
	public init(stringLiteral value: String) {
		self.init(rawValue: value)
	}
}

public struct KeyChain {
	/// Save data to Key Chain
	/// - Parameters:
	///   - data: Data to save
	///   - key: Key for the data
	///   - group: Key Chain to use, defaults to first one from available:
	///   	[Shared Keychain, Private Key Chain, Shared Group]
	/// - Returns: Status
	/// - Warning: When shared Key Chain is present, it will be used
	/// 	as a default one if no group provided. When no shared Key Chain
	/// 	present, a private app's Key Chain will be used.
	@discardableResult
	public static func save(
		_ data: Data,
		for key: String,
		at group: KeychainGroup? = .none
	) -> OSStatus {
		var query: [String: Any] = [
			      kSecClass as String: kSecClassGenericPassword as String,
			kSecAttrAccount as String: key,
			  kSecValueData as String: data
		]
		
		if let group = group {
			query[kSecAttrAccessGroup as String] = group.rawValue
		}
		
		SecItemDelete(query as CFDictionary)
		return SecItemAdd(query as CFDictionary, .none)
		
		/// Debug status
		/*
		let addStatus = SecItemAdd(query as CFDictionary, .none)
		let readableStatus = SecCopyErrorMessageString(addStatus, .none)
		print("=== keychain add status: \(readableStatus.orNilString)")
		return addStatus
		*/
	}
	
	@discardableResult
	/// Remove data from Key Chain
	/// - Parameters:
	///   - key: Key for the data
	///   - group: Key Chain to use, defaults to first one from available:
	///   	[Shared Keychain, Private Key Chain, Shared Group]
	/// - Returns: Status
	/// - Warning: When shared Key Chain is present, it will be used
	/// 	as a default one if no group provided. When no shared Key Chain
	/// 	present, a private app's Key Chain will be used.
	public static func remove(
		for key: String,
		at group: KeychainGroup? = .none
	) -> OSStatus {
		var query: [String: Any] = [
				  kSecClass as String: kSecClassGenericPassword as String,
			kSecAttrAccount as String: key
		]
		
		if let group = group {
			query[kSecAttrAccessGroup as String] = group.rawValue
		}
		
		return SecItemDelete(query as CFDictionary)
	}
	
	/// Get data from Key Chain
	/// - Parameters:
	///   - key: Key for the data
	///   - group: Key Chain to use, defaults to first one from available:
	///   	[Shared Keychain, Private Key Chain, Shared Group]
	/// - Returns: Data, if received with no errors
	/// - Warning: When shared Key Chain is present, it will be used
	/// 	as a default one if no group provided. When no shared Key Chain
	/// 	present, a private app's Key Chain will be used.
	public static func data(
		for key: String,
		at group: KeychainGroup? = .none
	) -> Data? {
		var query: [String: Any] = [
			      kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			 kSecReturnData as String: kCFBooleanTrue!,
			 kSecMatchLimit as String: kSecMatchLimitOne
		]
		
		if let group = group {
			query[kSecAttrAccessGroup as String] = group.rawValue
		}
		
		var data: AnyObject? = .none
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &data)
		
		if status == noErr {
			return data as! Data?
		}
		
		return .none
	}
}
