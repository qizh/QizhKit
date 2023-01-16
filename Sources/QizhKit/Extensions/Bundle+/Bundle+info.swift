//
//  Bundle+info.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 16.01.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Bundle + info.plist

public enum InfoPlistKeys: String {
	case bundleDisplayName = "CFBundleDisplayName"
	case bundleName = "CFBundleName"
	
	case bundleVersion = "CFBundleVersion"
	case bundleVersionShort = "CFBundleShortVersionString"
	
	case bundleURLTypes = "CFBundleURLTypes"
	case applicationQueriesSchemes = "LSApplicationQueriesSchemes"
}

extension Bundle {
	@inlinable public var displayName: String? { self[info: .bundleDisplayName] as? String }
	@inlinable public var name: String? { self[info: .bundleName] as? String }
	
	@inlinable public var version: String? { self[info: .bundleVersion] as? String }
	@inlinable public var versionShort: String? { self[info: .bundleVersionShort] as? String }
	
	@inlinable public var urlTypes: [String: AnyHashable]? {
		self[info: .bundleURLTypes] as? [String: AnyHashable]
	}
	
	@inlinable public var queriesSchemes: [String]? {
		self[info: .applicationQueriesSchemes] as? [String]
	}
}

// MARK: Bundle + subscript

extension Bundle {
	@inlinable
	public subscript(info key: String) -> Any? {
		object(forInfoDictionaryKey: key)
	}
	
	@inlinable
	public subscript(info key: CodingKey) -> Any? {
		object(forInfoDictionaryKey: key.stringValue)
	}
	
	@inlinable
	public subscript(info key: some RawRepresentable<String>) -> Any? {
		object(forInfoDictionaryKey: key.rawValue)
	}
	
	@inlinable
	public subscript(info key: InfoPlistKeys) -> Any? {
		object(forInfoDictionaryKey: key.rawValue)
	}
}
