//
//  Dictionary+CodingKey.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.05.2022.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Dictionary where Key == String {
	/// Use key's `stringValue` as a dictionary key
	@inlinable public subscript(_ key: CodingKey) -> Value? {
		get { self[key.stringValue] }
		set { self[key.stringValue] = newValue }
	}
	
	/// Use key's `rawValue` as a dictionary key
	@inlinable public subscript(_ key: some RawRepresentable<String>) -> Value? {
		get { self[key.rawValue] }
		set { self[key.rawValue] = newValue }
	}
}
