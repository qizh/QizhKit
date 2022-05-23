//
//  Dictionary+CodingKey.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.05.2022.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Dictionary
	where Key == String,
		  Value == Any
{
	/// Use key's `stringValue` as a dictionary key
	public subscript(key: CodingKey) -> Value? {
		get { self[key.stringValue] }
		set { self[key.stringValue] = newValue }
	}
}
