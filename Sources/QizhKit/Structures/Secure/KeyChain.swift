//
//  KeyChain.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 07.06.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Security

public struct KeychainGroup: RawRepresentable, ExpressibleByStringLiteral {
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
	}
	
	@discardableResult
	public static func remove(for key: String) -> OSStatus {
		let query: [String: Any] = [
				  kSecClass as String: kSecClassGenericPassword as String,
			kSecAttrAccount as String: key
		]
		
		return SecItemDelete(query as CFDictionary)
	}
	
	public static func data(for key: String) -> Data? {
		let query: [String: Any] = [
			      kSecClass as String: kSecClassGenericPassword,
			kSecAttrAccount as String: key,
			 kSecReturnData as String: kCFBooleanTrue!,
			 kSecMatchLimit as String: kSecMatchLimitOne
		]
		
		var data: AnyObject? = .none
		let status: OSStatus = SecItemCopyMatching(query as CFDictionary, &data)
		
		if status == noErr {
			return data as! Data?
		}
		
		return .none
	}
}
