//
//  JSON5Encoder.swift
//  BespokelyKit
//
//  Created by Serhii Shevchenko on 08.01.2025.
//  Copyright © 2025 Bespokely. All rights reserved.
//

public import Foundation
public import Combine
import RegexBuilder

// MARK: JSON5

public final class JSON5Encoder: TopLevelEncoder, @unchecked Sendable {
	fileprivate var encoder: JSONEncoder = .init()
	fileprivate let regexes = Regexes()
	
	public init() { }
	
	// MARK: ┣ Encode
	
	public func encode<T: Encodable>(_ value: T) throws -> String {
		let jsonData = try encoder.encode(value)
		
		guard let jsonString = String(data: jsonData, encoding: .utf8) else {
			throw EncodingError.invalidValue(
				value,
				EncodingError.Context(
					codingPath: [],
					debugDescription: "Failed to convert JSON data to string"
				)
			)
		}
		
		let json5String = convertToUnquotedPropertyNames(jsonString)
		return json5String
	}
	
	// MARK: ┣ Remove quotes
	
	fileprivate func convertToUnquotedPropertyNames(_ jsonString: String) -> String {
		
		jsonString.replacing(regexes.quotedPropertyNameRegex) { match in
			match[regexes.propertyNameRef] + .colon
		}
	}
}

// MARK: ┣ Pass Properties
	
extension JSON5Encoder {
	public var outputFormatting: JSONEncoder.OutputFormatting {
		get { encoder.outputFormatting }
		set { encoder.outputFormatting = newValue }
	}
	
	public var dateEncodingStrategy: JSONEncoder.DateEncodingStrategy {
		get { encoder.dateEncodingStrategy }
		set { encoder.dateEncodingStrategy = newValue }
	}
	
	public var dataEncodingStrategy: JSONEncoder.DataEncodingStrategy {
		get { encoder.dataEncodingStrategy }
		set { encoder.dataEncodingStrategy = newValue }
	}
	
	public var keyEncodingStrategy: JSONEncoder.KeyEncodingStrategy {
		get { encoder.keyEncodingStrategy }
		set { encoder.keyEncodingStrategy = newValue }
	}
	
	public var nonConformingFloatEncodingStrategy: JSONEncoder.NonConformingFloatEncodingStrategy {
		get { encoder.nonConformingFloatEncodingStrategy }
		set { encoder.nonConformingFloatEncodingStrategy = newValue }
	}
	
	#if swift(>=6.1)
	/// Works in Xcode 16.3
	public var userInfo: [CodingUserInfoKey: any Sendable] {
		get { encoder.userInfo }
		set { encoder.userInfo = newValue }
	}
	
	#else
	/// Works in Xcode 16.2
	public var userInfo: [CodingUserInfoKey: Any] {
		get { encoder.userInfo }
		set { encoder.userInfo = newValue }
	}
	#endif
}

// MARK: ┣ Regexes

extension JSON5Encoder {
	fileprivate struct Regexes {
		let propertyNameRef = Reference(String.self)
		var quotedPropertyNameRegex: Regex<(Substring, String)> {
			Regex {
				String.quot
				TryCapture(as: propertyNameRef) {
					CharacterClass(
						.anyOf("_"),
						("a"..."z"),
						("A"..."Z")
					)
					ZeroOrMore {
						CharacterClass(
							.anyOf("_"),
							("a"..."z"),
							("A"..."Z"),
							("0"..."9")
						)
					}
				} transform: { substring in
					String(substring)
				}
				String.quot
				ZeroOrMore(.whitespace)
				":"
			}
		}
	}
}

// MARK: ┗ Constants

extension JSON5Encoder {
	public static let prettyPrinted: JSON5Encoder = {
		let encoder = JSON5Encoder()
		encoder.outputFormatting = .prettyPrinted
		return encoder
	}()
}

// MARK: - String Interpolation

public extension DefaultStringInterpolation {
	// MARK: Encode JSON5
	
	mutating func appendInterpolation(
		json5 value: some Encodable,
		encoder providedEncoder: JSON5Encoder? = .none
	) {
		let encoder: JSON5Encoder = providedEncoder ?? .prettyPrinted
		
		do {
			let jsonString = try encoder.encode(value)
			appendLiteral(jsonString)
		} catch {
			appendLiteral(error.localizedDescription)
		}
	}
	
	mutating func appendInterpolation(
		json5 value: (any Sendable)?,
		encoder providedEncoder: JSON5Encoder? = .none
	) {
		let encoder: JSON5Encoder = providedEncoder ?? .prettyPrinted

		do {
			let jsonString = try encoder.encode(AnyEncodable(value))
			appendLiteral(jsonString)
		} catch {
			appendLiteral(error.localizedDescription)
		}
	}
}
