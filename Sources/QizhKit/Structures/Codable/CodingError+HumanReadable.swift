//
//  CodingError+HumanReadable.swift
//  
//
//  Created by Serhii Shevchenko on 01.08.2023.
//

import Foundation

extension DecodingError {
	public var humanReadableDescription: String {
		switch self {
		case let .keyNotFound(key, context):
			let debugDescription = context.debugDescription
				.nonEmpty.map { "\n\($0)" } ?? .empty
			return "DecodingError.keyNotFound(\(key.stringValue.inQuotes) at \(context.codingPath.humanReadableDescription))\(debugDescription)"
		case let .typeMismatch(type, context):
			let debugDescription = context.debugDescription
				.nonEmpty.map { "\n\($0)" } ?? .empty
			return "DecodingError.typeMismatch(\(type.self) at \(context.codingPath.humanReadableDescription))\(debugDescription)"
		case let .valueNotFound(type, context):
			let debugDescription = context.debugDescription
				.nonEmpty.map { "\n\($0)" } ?? .empty
			return "DecodingError.valueNotFound(at \(context.codingPath.humanReadableDescription), type: \(type.self))\(debugDescription)"
		case let .dataCorrupted(context):
			let debugDescription = context.debugDescription
				.nonEmpty.map { "\n\($0)" } ?? .empty
			return "DecodingError.dataCorrupted(at \(context.codingPath.humanReadableDescription))\(debugDescription)"
		@unknown default:
			return "\(self)"
		}
	}
}

extension Array where Element == CodingKey {
	@inlinable public var humanReadableDescription: String {
		map(\.pathPartDescription).joined(separator: .spaceArrowSpace)
	}
}

extension CodingKey {
	public var pathPartDescription: String {
		if let index = intValue {
			"[\(index)]"
		} else if stringValue.contains(.whitespaces) {
			"\"\(stringValue)\""
		} else {
			stringValue
		}
	}
}
