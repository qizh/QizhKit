//
//  PrettyStringConvertable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 22.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// Provides default implementations.
/// ``description``: Entity name (and id when ``Identifiable``),
/// ``debugDescription``: JSON representation
public protocol PrettyStringConvertable:
	CustomDebugStringConvertible,
	CustomStringConvertible,
	Encodable
{ }

extension PrettyStringConvertable {
	/// JSON representation
	public var debugDescription: String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		do {
			let encoded = try encoder.encode(self)
			let string = String(decoding: encoded, as: UTF8.self)
			return string
		} catch {
			print(
				"""
				⚠️ [PrettyStringConvertable]
					┣ `debugDescription` failed for > \(Self.self)
					┣ JSON encoding error > \(error.localizedDescription)
					┣ fallback to > \(description)
				"""
			)
			return description
		}
	}
	
	/// Model entity name and id
	public var description: String {
		caseName(of: Self.self, .name) + debugIdentifier()
	}
	
	@_disfavoredOverload
	private func debugIdentifier() -> String { .empty }
	private func debugIdentifier() -> String where Self: Identifiable {
		"(\(self.id))"
	}
}
