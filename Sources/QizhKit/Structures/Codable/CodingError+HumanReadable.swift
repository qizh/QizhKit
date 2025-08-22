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
				.nonEmpty.map { ", description: \($0)" } ?? .empty
			return "DecodingError.keyNotFound(\"\(key.stringValue)\" key at \(context.codingPath.humanReadableDescription)\(debugDescription))"
		case let .typeMismatch(type, context):
			let debugDescription = context.debugDescription
				.nonEmpty.map { ", description: \($0)" } ?? .empty
			return "DecodingError.typeMismatch(\(type) type at \(context.codingPath.humanReadableDescription)\(debugDescription))"
		case let .valueNotFound(type, context):
			let debugDescription = context.debugDescription
				.nonEmpty.map { ", description: \($0)" } ?? .empty
			return "DecodingError.valueNotFound(\(type) type at \(context.codingPath.humanReadableDescription)\(debugDescription))"
		case let .dataCorrupted(context):
			let debugDescription = context.debugDescription
				.nonEmpty.map { ", description: \($0)" } ?? .empty
			return "DecodingError.dataCorrupted(at \(context.codingPath.humanReadableDescription)\(debugDescription))"
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
		.joined(separator: .spaceArrowSpace)
	}
}
