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
			return "DecodingError.keyNotFound(\"\(key.stringValue)\" key at \(context.codingPath.humanReadableDescription))"
		case let .typeMismatch(type, context):
			return "DecodingError.typeMismatch(\(type) type at \(context.codingPath.humanReadableDescription))"
		case let .valueNotFound(type, context):
			return "DecodingError.valueNotFound(\(type) type at \(context.codingPath.humanReadableDescription))"
		case let .dataCorrupted(context):
			return "DecodingError.dataCorrupted(at \(context.codingPath.humanReadableDescription))"
		@unknown default:
			return "\(self)"
		}
	}
}

extension Array where Element == CodingKey {
	@inlinable public var humanReadableDescription: String {
		map { key in
			key.intValue?.s ?? key.stringValue
		}
		.joined(separator: .dot)
	}
}
