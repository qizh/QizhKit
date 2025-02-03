//
//  DecodingError+prettyDescription.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.02.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

fileprivate struct DecodingErrorPrettyPrinter: CustomStringConvertible, CustomDebugStringConvertible {
	let decodingError: DecodingError
	
	init(decodingError: DecodingError) {
		self.decodingError = decodingError
	}
	
	private let prefix = "Decoding Error"
	
	private func codingKeyDescription(_ key: CodingKey) -> String {
		if let index = key.intValue {
			"[\(index)]"
		} else if key.stringValue.contains(.whitespaces) {
			"[\(key.stringValue)]"
		} else {
			key.stringValue
		}
	}
	
	private func codingPathDescription(_ path: [CodingKey]) -> String {
		path.map(codingKeyDescription).joined(separator: " → ")
	}
	
	private func additionalComponents(for _: DecodingError) -> [String] {
		switch decodingError {
		case let .valueNotFound(_, context):
			[
				codingPathDescription(context.codingPath),
				context.debugDescription,
			]
		case let .keyNotFound(key, context):
			[
				codingPathDescription(context.codingPath),
				"Key not found: \(codingKeyDescription(key))",
			]
		case let .typeMismatch(type, context):
			[
				codingPathDescription(context.codingPath),
				"Type mismatch. Expected: \(type)",
			]
		case let .dataCorrupted(context):
			[
				codingPathDescription(context.codingPath),
				context.debugDescription,
			]
		@unknown default:
			.just(decodingError.localizedDescription)
		}
	}
	
	var description: String {
		additionalComponents(for: decodingError)
			.prepending(prefix)
			.joined(separator: .colon)
	}
	
	var debugDescription: String {
		description
	}
}

extension DecodingError {
	public var prettyDescription: String {
		DecodingErrorPrettyPrinter(decodingError: self).description
	}
}
