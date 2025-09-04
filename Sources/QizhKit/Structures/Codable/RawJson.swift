//
//  RawJson.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.12.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// Stores raw JSON bytes and helps encode/decode heterogenous JSON (array or dictionary).
/// Use as a property wrapper to keep the original JSON `Data`.
@propertyWrapper
public struct RawJson: Sendable, Hashable {
	/// Underlying raw JSON bytes.
	public var wrappedValue: Data
	
	/// Creates an empty raw JSON container.
	/// - Parameter wrappedValue: Initial JSON data. Defaults to empty `Data()`.
	public init(wrappedValue: Data = .init()) {
		self.wrappedValue = wrappedValue
	}
	
	/// Encodes a heterogeneous JSON-compatible dictionary to raw data.
	/// - Parameter dictionary: `String`-keyed, `Sendable` values.
	/// - Throws: Encoding errors.
	public init(encoding dictionary: [String: any Sendable]) throws {
		let wrappedDictionary = CodableAnyDictionary(wrappedValue: dictionary)
		try self.init(encoding: wrappedDictionary)
	}
	
	/// Encodes a heterogeneous JSON-compatible array to raw data.
	/// - Parameter array: Array of `Sendable & Encodable`.
	/// - Throws: Encoding errors.
	public init(encoding array: [any (Sendable & Encodable)]) throws {
		let wrappedArray = CodableAnyArray(wrappedValue: array)
		try self.init(encoding: wrappedArray)
	}
	
	/// Encodes a `CodableAnyDictionary` to raw JSON data.
	/// - Parameter wrappedDictionary: Heterogeneous dictionary wrapper.
	/// - Throws: Encoding errors.
	public init(encoding wrappedDictionary: CodableAnyDictionary) throws {
		let encoder = JSONEncoder()
		let data = try encoder.encode(wrappedDictionary)
		self.init(wrappedValue: data)
	}

	/// Encodes a `CodableAnyArray` to raw JSON data.
	/// - Parameter wrappedArray: Heterogeneous array wrapper.
	/// - Throws: Encoding errors.
	public init(encoding wrappedArray: CodableAnyArray) throws {
		let encoder = JSONEncoder()
		let data = try encoder.encode(wrappedArray)
		self.init(wrappedValue: data)
	}

	/// Decodes raw JSON as a `CodableAnyDictionary`.
	/// - Returns: Heterogeneous dictionary wrapper.
	/// - Throws: Decoding errors.
	public func asCodableDictionary() throws -> CodableAnyDictionary {
		let decoder = JSONDecoder()
		let wrappedDictionary = try decoder.decode(CodableAnyDictionary.self, from: wrappedValue)
		return wrappedDictionary
	}
	
	/// Decodes raw JSON as a `CodableAnyArray`.
	/// - Returns: Heterogeneous array wrapper.
	/// - Throws: Decoding errors.
	public func asCodableArray() throws -> CodableAnyArray {
		let decoder = JSONDecoder()
		let wrappedDictionary = try decoder.decode(CodableAnyArray.self, from: wrappedValue)
		return wrappedDictionary
	}
}

// Explicit Equatable to avoid synthesized-equality linker issues.
extension RawJson: Equatable {
	/// Compares underlying raw bytes.
	public static func == (lhs: RawJson, rhs: RawJson) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
}

extension RawJson: Codable {
	/// Tries to decode either a dictionary or an array from the decoder into raw JSON.
	/// - Throws: `FetchError.multipleErrors` with all decode failures.
	public init(from decoder: Decoder) throws {
		var errors: [any Error] = .empty
		
		do {
			let wrappedDictionary = try CodableAnyDictionary(from: decoder)
			try self.init(encoding: wrappedDictionary)
			return
		} catch {
			errors.append(error)
		}
		
		do {
			let wrappedArray = try CodableAnyArray(from: decoder)
			try self.init(encoding: wrappedArray)
			return
		} catch {
			errors.append(error)
		}
		
		throw FetchError.multipleErrors(errors)
	}
	
	/// Encodes underlying raw JSON as either a dictionary or an array.
	/// - Throws: `FetchError.multipleErrors` with all encode failures.
	public func encode(to encoder: Encoder) throws {
		var errors: [any Error] = .empty
		
		do {
			let wrappedDictionary = try asCodableDictionary()
			try wrappedDictionary.encode(to: encoder)
			return
		} catch {
			errors.append(error)
		}
		
		do {
			let wrappedArray = try asCodableArray()
			try wrappedArray.encode(to: encoder)
			return
		} catch {
			errors.append(error)
		}
		
		throw FetchError.multipleErrors(errors)
	}
}

extension RawJson: CustomStringConvertible {
	/// UTF-8 string representation of the raw JSON, or a placeholder if invalid.
	public var description: String {
		String(data: wrappedValue, encoding: .utf8) ?? "<invalid data>"
	}
}

extension RawJson: RawRepresentable {
	/// Initializes from a UTF-8 string.
	public init?(rawValue: String) {
		guard let data = rawValue.data(using: .utf8) else { return nil }
		self.wrappedValue = data
	}
	
	/// Returns a UTF-8 string, or a placeholder if invalid.
	public var rawValue: String {
		String(data: wrappedValue, encoding: .utf8) ?? "<invalid data>"
	}
}

extension RawJson: EmptyComparable {
	/// An empty raw JSON value (`Data()`).
	public static var empty: RawJson { .init(wrappedValue: Data()) }
}

extension RawJson: ExpressibleByStringLiteral {
	/// Initializes from a UTF-8 string literal.
	public init(stringLiteral value: String) {
		self.init(wrappedValue: value.data(using: .utf8) ?? Data())
	}
}
