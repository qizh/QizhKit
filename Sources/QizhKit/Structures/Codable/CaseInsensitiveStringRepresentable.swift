//
//  File.swift
//  
//
//  Created by Serhii Shevchenko on 24.12.2020.
//

import Foundation

public protocol CaseInsensitiveStringRepresentable {
	init?(caseInsensitiveRawValue: String)
}

public extension CaseInsensitiveStringRepresentable
	where Self: RawRepresentable,
		  RawValue == String
{
	init?(caseInsensitiveRawValue: String) {
		self.init(rawValue: caseInsensitiveRawValue.lowercased())
	}
}

public extension CaseInsensitiveStringRepresentable
	where Self: RawRepresentable,
		  RawValue == String,
		  Self: CaseIterable
{
	init?(caseInsensitiveRawValue: String) {
		if let result = Self.allCases.first(
			where: \.stringValue.localizedLowercase,
			equals: caseInsensitiveRawValue.localizedLowercase
		) {
			self = result
		} else {
			return nil
		}
	}
}

/*
public extension CaseInsensitiveStringRepresentable where Self: Decodable {
	init(from decoder: Decoder) throws {
		let container = try decoder.singleValueContainer()
		let value = try container.decode(String.self)
		
		if let result = Self.init(caseInsensitiveRawValue: value) {
			self = result
		} else {
			throw DecodingError.dataCorruptedError(
				in: container,
				debugDescription: "Failed to create `\(Self.self)` with `\(value)` value"
			)
		}
	}
}
*/

public extension KeyedDecodingContainer {
	func decodeIfPresent <Result> (_: Result.Type, forKey key: Key) -> Result? where Result: CaseInsensitiveStringRepresentable {
		if let rawValue = try? decodeIfPresent(String.self, forKey: key),
		   let value = Result(caseInsensitiveRawValue: rawValue) {
			return value
		}
		return nil
	}
}
