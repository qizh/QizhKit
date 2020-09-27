//
//  PrettyStringConvertable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 22.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public protocol PrettyStringConvertable:
	CustomDebugStringConvertible,
	CustomStringConvertible,
	Encodable
{ }

public extension PrettyStringConvertable {
	var description: String {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		
		do {
			let encoded = try encoder.encode(self)
			let string = String(decoding: encoded, as: UTF8.self)
			return string
		} catch {
			return error.localizedDescription
		}
	}
	
	var debugDescription: String {
		caseName(of: Self.self, .name) + debugIdentifier()
	}
	
	private func debugIdentifier() -> String { .empty }
	private func debugIdentifier() -> String where Self: Identifiable {
		"(\(self.id))"
	}
}
