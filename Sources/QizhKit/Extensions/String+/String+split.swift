//
//  String+split.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	func split(by length: Int) -> [String] {
		stride(from: 0, to: count, by: length)
			.map { offset in
				let start = index(startIndex, offsetBy: offset)
				let end = index(start, offsetBy: length, limitedBy: endIndex) ?? endIndex
				return String(self[start ..< end])
			}
	}
}

public extension Array where Element == Character {
	@inlinable func asString() -> String {
		String(self)
	}
}

extension String {
	/// Splits the string into chunks to accommodate a specified maximum length,
	/// considering line breaks as the preferred splitting points.
	///
	/// - Parameters:
	///   - maxLength: The maximum length of each output chunk. The default value is 1024.
	/// - Returns: An array of `Substring` chunks.
	///
	/// - Note: The function iterates through the original string and creates chunks of text
	///         based on the specified maximum length. If a line break character (`\n`) is
	///         found within the chunk, the split occurs at the line break. If no line break
	///         character is present, the function tries to split at the last space character
	///         before the maxLength. If no space is found, the chunk is split at the
	///         maxLength. The line break character or space character (if used for
	///         splitting) is dropped from the output.
	///
	/// - Complexity: The time complexity is O(n), where n is the number of characters
	/// 		in the string.
	///               The function iterates through the string once to create the chunks.
	public func splittedForLogger(maxLength: Int = 30000) -> [Substring] {
		var chunks: [Substring] = []
		var currentIndex = self.startIndex
		
		while currentIndex < self.endIndex {
			let remainingLength = self.distance(from: currentIndex, to: self.endIndex)
			let chunkLength = min(maxLength, remainingLength)
			let nextIndex = self.index(currentIndex, offsetBy: chunkLength)
			let chunk = self[currentIndex..<nextIndex]
			
			if chunkLength == remainingLength {
				/// Last chunk
				chunks.append(chunk)
				break
			}
			
			/// Attempt to find the last line break character within the chunk
			/// If not found, attempt to find the last space character
			/// If neither line break nor space character is found, split at the maxLength
			let splitIndex = chunk.lastIndex { character in
				CharacterSet.newlines.contains(character.unicodeScalars.first ?? .init(0))
			} ?? chunk.lastIndex { character in
				CharacterSet.whitespaces.contains(character.unicodeScalars.first ?? .init(0))
			} ?? chunk.endIndex
			
			let splitChunk = self[currentIndex..<splitIndex]
			chunks.append(splitChunk)
			currentIndex = splitIndex < chunk.endIndex ? self.index(after: splitIndex) : nextIndex
		}
		
		return chunks
	}
	
	@inlinable public func forEachLoggerChunk(
		maxLength: Int = 30000,
		_ body: (Substring) throws -> Void
	) rethrows {
		try self
			.splittedForLogger(maxLength: maxLength)
			.forEach(body)
	}
}
