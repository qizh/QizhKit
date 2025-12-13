//
//  AutoTypeCodable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.11.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// A property wrapper that decodes a value of type `T` from a variety of `JSON`
/// representations and encodes it back as `T`.
///
/// Use this when the upstream payload is inconsistent. For example, when numbers sometimes
/// arrive as strings or booleans are represented as `0`/`1`.
/// - Requires:
///   - `T` must conform to `LosslessStringConvertible` and `Codable`.
/// ## Decoding:
/// - First attempts to decode `T` directly.
/// - If that `fails`, it tries common primitives
///   - `String`
///   - `Bool` (including `NSNumber` `0`/`1`)
///   - integer types
///   - floating‑point types
///   - `Decimal`
///   - `Date`
/// - The first successfully decoded value is then converted to `T`
///   via its lossless string initializer.
/// ## Encoding:
/// - Converts the wrapped value to a `String` and re‑initializes `T` from that string
///   to preserve the canonical representation before encoding.
/// ## Usage:
/// ```swift
/// struct Payload: Codable {
///     /// Accepts numbers or strings like "42" and encodes as an `Int`.
///     @AutoTypeCodable var intValue: Int
///
///     /// Accepts strings like "3.14" or numeric doubles.
///     @AutoTypeCodable var doubleValue: Double
///
///     /// Accepts string or numeric representations of decimals.
///     @AutoTypeCodable var price: Decimal
///
///     /// Accepts a date string in format "dd.MM.yyyy HH:mm" or `null`.
///     @AutoTypeCodable var scheduledAt: Date?
/// }
///
/// let json = """
/// 	{
/// 		"intValue": "42",
/// 		"doubleValue": 3.14,
/// 		"price": "10.50",
/// 		"scheduledAt": "01.01.2021 13:45"
/// 	}
/// 	"""
/// 	.data(using: .utf8)
/// 	.forceUnwrap(because: "Valid JSON string will be converted to Data")
///
/// let decoded = try JSONDecoder()
/// 	.decode(Payload.self, from: json)
///
/// // decoded.intValue == 42
/// // decoded.doubleValue == 3.14
/// // decoded.price == 10.50
/// // decoded.scheduledAt != nil
/// ```
@propertyWrapper
public struct AutoTypeCodable <T>: Codable where T: LosslessStringConvertible,
												 T: Codable {
	
	private typealias LosslessStringCodable = LosslessStringConvertible & Codable
	
	/// The underlying value managed by the property wrapper.
	public var wrappedValue: T

	/// Creates the wrapper with an initial value.
	/// - Parameter wrappedValue: The value to store and later encode/decode.
	public init(wrappedValue: T) {
		self.wrappedValue = wrappedValue
	}
	
	/// Decodes the wrapped value from the given decoder, accepting multiple source types
	/// as described in the type documentation.
	/// - Parameter decoder: The decoder to read data from.
	/// - Throws: Any error thrown by the underlying `Decodable` implementations
	///   or if no compatible representation can be converted to `T`.
	public init(from decoder: Decoder) throws {
		do {
			self.wrappedValue = try T.init(from: decoder)
		} catch let error {
			
			func decode<D: LosslessStringCodable>(_: D.Type) -> (Decoder) -> LosslessStringCodable? {
				{ try? D.init(from: $0) }
			}
			
			func decodeBoolFromNSNumber() -> (Decoder) -> LosslessStringCodable? {
				{ decoder in
					(try? Int(from: decoder))
						.flatMap { int in
							Bool(exactly: NSNumber(value: int))
						}
				}
			}
			
			let types: [(Decoder) -> LosslessStringCodable?] = [
				decode(String.self),
				decodeBoolFromNSNumber(),
				decode(Bool.self),
				decode(Int.self),
				decode(UInt.self),
				decode(Decimal.self),
				decode(Double.self),
				decode(Float.self),
				decode(Date.self),
				decode(Int8.self),
				decode(Int16.self),
				decode(Int64.self),
				decode(UInt8.self),
				decode(UInt16.self),
				decode(UInt64.self),
			]
			
			guard let rawValue = types.lazy.compactMap({ $0(decoder) }).first,
				  let value = T("\(rawValue)")
			else { throw error }
			
			self.wrappedValue = value
		}
	}
	
	/// Encodes the wrapped value using `T`'s `Encodable` conformance.
	///
	/// The value is first round‑tripped through `String(describing:)` and `T.init(_:)`
	/// to preserve the canonical representation before encoding.
	/// - Parameter encoder: The encoder to write data to.
	/// - Throws: `EncodingError.invalidValue` if the value cannot be reconstructed
	///   from its string description.
	public func encode(to encoder: Encoder) throws {
		let string = String(describing: wrappedValue)
		
		guard let original = T.self.init(string) else {
			let description = "Unable to encode `\(wrappedValue)` back to source type `\(T.self)`"
			throw EncodingError.invalidValue(string, .init(codingPath: [], debugDescription: description))
		}
		
		try original.encode(to: encoder)
	}
}

public extension KeyedDecodingContainer {
	/// Decodes an `AutoTypeCodable<T>` for the given key, defaulting to `T.none`
	/// when the key is missing or the value is `null`.
	///
	/// This overload is available when `T` is an optional‑like type
	/// that conforms to `TypedOptionalConvertible`.
	/// - Parameters:
	///   - type: The `AutoTypeCodable<T>` type to decode.
	///   - key: The key that the decoded value is associated with.
	/// - Returns: A wrapper containing the decoded value or `.none`.
	func decode<T: TypedOptionalConvertible>(
		_: AutoTypeCodable<T>.Type,
		forKey key: Key
	) -> AutoTypeCodable<T> {
		(try? decodeIfPresent(AutoTypeCodable<T>.self, forKey: key))
		?? AutoTypeCodable<T>(wrappedValue: .none)
	}
}

extension Optional: @retroactive LosslessStringConvertible where Wrapped: LosslessStringConvertible {
	/// Creates an optional from a string by delegating
	/// to the wrapped type's lossless initializer.
	/// - Returns:
	///   - If `Wrapped(description)` succeeds
	///     ```swift
	///     .some(value)
	///     ```
	///   - Otherwise
	///     ```swift
	///     nil
	///     ```
	/// - Parameter description: A string representation of the wrapped value.
	public init?(_ description: String) {
		self = Wrapped.init(description)
	}
	
	/// A textual representation of the optional.
	/// - Returns:
	///   - An empty string for `.none`
	///   - The wrapped value's description for `.some`
	public var description: String {
		switch self {
		case .none: return .empty
		case .some(let value): return value.description
		}
	}
}

extension AutoTypeCodable: Equatable where T: Equatable {
	/// Returns `true` if both wrappers contain equal values.
	public static func == (lhs: AutoTypeCodable<T>, rhs: AutoTypeCodable<T>) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
}

extension AutoTypeCodable: Hashable where T: Hashable {
	/// Hashes the wrapped value into the provided hasher.
	/// - Parameter hasher: The hasher to use when combining the components of this instance.
	public func hash(into hasher: inout Hasher) {
		hasher.combine(wrappedValue)
	}
}

extension AutoTypeCodable: Sendable where T: Sendable { }

// MARK: Adopt

extension Date: @retroactive LosslessStringConvertible {
	/// Creates a `Date` from a string using a best‑effort strategy.
	///
	/// Attempts to parse using the `"dd.MM.yyyy HH:mm"` format in the current time zone;
	/// otherwise falls back to `DateFormatter().date(from:)`.
	/// - Parameter description: A string representation of a date.
	public init?(_ description: String) {
		#if swift(>=5.5)
		do {
			try self.init(
				description,
				strategy: Date.ParseStrategy(
					format: """
						\(day: .twoDigits).\(month: .twoDigits).\(year: .defaultDigits) \
						\(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\
						\(minute: .twoDigits)
						""",
					timeZone: .current
				)
			)
		} catch {
			if let date = DateFormatter().date(from: description) {
				self = date
			} else {
				return nil
			}
		}
		#else
		if let date = DateFormatter().date(from: description) {
			self = date
		} else {
			return nil
		}
		#endif
	}
}

extension Decimal: @retroactive LosslessStringConvertible {
	/// Creates a `Decimal` from its string representation.
	/// - Parameter description: A string representation of a decimal number.
	public init?(_ description: String) {
		self.init(string: description)
	}
}

// MARK: - Defaulted

/// A variant of `AutoTypeCodable` that tolerates decoding failures
/// by providing a reasonable default value.
///
/// Use this when you prefer resilient decoding and want to avoid throwing
/// for inconsistent server payloads.
/// ## Defaulting behavior
/// - If decoding fails or the value is missing, attempts to build a default
///   by trying `T("false")` and then `T("0")`.
/// - For optional‑like `T` (i.e., types conforming to `TypedOptionalConvertible`),
///   defaults to `.none` if both attempts fail.
/// ## Usage
/// ```swift
/// struct LossyPayload: Codable {
///     // Defaults to 0 when value is missing or invalid
///     @LossyAutoTypeCodable var count: Int
///
///     // Defaults to `.none` when value is missing or invalid
///     @LossyAutoTypeCodable var maybeID: Int?
/// }
///
/// // Missing keys: produces defaults
/// let missing = try JSONDecoder()
/// 	.decode(LossyPayload.self, from: Data("{}".utf8))
/// // missing.count == 0
/// // missing.maybeID == nil
///
/// // Invalid types: still produces defaults
/// let invalidJSON = """
/// 	{
/// 		"count": "oops",
/// 		"maybeID": "nope"
/// 	}
/// 	"""
/// 	.data(using: .utf8)
/// 	.forceUnwrap(because: "Valid JSON string will be converted to Data")
/// let invalid = try JSONDecoder()
/// 	.decode(LossyPayload.self, from: invalidJSON)
/// // invalid.count == 0
/// // invalid.maybeID == nil
/// ```
@propertyWrapper
public struct LossyAutoTypeCodable<T>: Codable
	where T: LosslessStringConvertible,
		  T: Codable
{
	private typealias LosslessStringCodable = LosslessStringConvertible & Codable
	
	/// The underlying value managed by the property wrapper.
	/// When decoding fails, this may be initialized to a default value.
	public var wrappedValue: T
	
	/// Creates the wrapper with an initial value.
	/// - Parameter wrappedValue: The value to store and later encode/decode.
	public init(wrappedValue: T) {
		self.wrappedValue = wrappedValue
	}
	
	/// Decodes the wrapped value from the given decoder.
	/// If decoding fails, a default value is used as described in the type documentation.
	/// - Parameter decoder: The decoder to read data from.
	public init(from decoder: Decoder) throws {
		do {
			self.wrappedValue = try T.init(from: decoder)
		} catch let error {
			
			func decode <D: LosslessStringCodable> (_: D.Type) -> (Decoder) -> LosslessStringCodable? {
				{ decoder in
					try? D(from: decoder)
				}
			}
			
			func decodeBoolFromNSNumber() -> (Decoder) -> LosslessStringCodable? {
				{ decoder in
					(try? Int.init(from: decoder))
						.flatMap { int in
							Bool(exactly: NSNumber(value: int))
						}
				}
			}
			
			let types: [(Decoder) -> LosslessStringCodable?] = [
				decode(String.self),
				decodeBoolFromNSNumber(),
				decode(Bool.self),
				decode(Int.self),
				decode(UInt.self),
				decode(Decimal.self),
				decode(Double.self),
				decode(Float.self),
				decode(Date.self),
				decode(Int8.self),
				decode(Int16.self),
				decode(Int64.self),
				decode(UInt8.self),
				decode(UInt16.self),
				decode(UInt64.self),
			]
			
			guard let rawValue = types.lazy.compactMap({ $0(decoder) }).first,
				  let value = T("\(rawValue)")
			else { throw error }
			
			self.wrappedValue = value
		}
	}
	
	/// Encodes the wrapped value using `T`'s `Encodable` conformance.
	/// - SeeAlso: `AutoTypeCodable.encode(to:)` for details on the round‑trip strategy.
	/// - Parameter encoder: The encoder to write data to.
	public func encode(to encoder: Encoder) throws {
		let string = String(describing: wrappedValue)
		
		guard let original = T.self.init(string) else {
			let description = "Unable to encode `\(wrappedValue)` back to source type `\(T.self)`"
			throw EncodingError.invalidValue(string, .init(codingPath: [], debugDescription: description))
		}
		
		try original.encode(to: encoder)
	}
}

public extension KeyedDecodingContainer {
	/// Decodes a `LossyAutoTypeCodable<T>` for the given key.
	///
	/// If decoding fails or the value is missing, returns a wrapper
	/// initialized with a default value derived from `T("false")` or `T("0")`.
	/// - Parameters:
	///   - type: The `LossyAutoTypeCodable<T>` type to decode.
	///   - key: The key that the decoded value is associated with.
	/// - Returns: A wrapper containing the decoded or default value.
	/// - Throws: `DecodingError.dataCorrupted` if no default can be created.
	func decode<T>(
		_: LossyAutoTypeCodable<T>.Type,
		forKey key: Key
	) throws -> LossyAutoTypeCodable<T> {
		if let decoded = try? decodeIfPresent(LossyAutoTypeCodable<T>.self, forKey: key) {
			return decoded
		} else if let defaultValue = T("false") ?? T("0") {
			return .init(wrappedValue: defaultValue)
		} else {
			throw DecodingError.dataCorruptedError(
				forKey: key,
				in: self,
				debugDescription: "Neither can decode \(T.self) value nor create a default one"
			)
		}
	}
	
	/// Decodes a `LossyAutoTypeCodable<T>` for the given key when `T` is optional‑like.
	///
	/// If decoding fails or the value is missing, returns a wrapper initialized
	/// with a default value derived from `T("false")` or `T("0")`, or `.none`
	/// if neither can be constructed.
	/// - Parameters:
	///   - type: The `LossyAutoTypeCodable<T>` type to decode.
	///   - key: The key that the decoded value is associated with.
	/// - Returns: A wrapper containing the decoded or default value.
	func decode<T: TypedOptionalConvertible>(
		_: LossyAutoTypeCodable<T>.Type,
		forKey key: Key
	) throws -> LossyAutoTypeCodable<T> {
		if let decoded = try? decodeIfPresent(LossyAutoTypeCodable<T>.self, forKey: key) {
			decoded
		} else if let defaultValue = T("false") ?? T("0") {
			.init(wrappedValue: defaultValue)
		} else {
			.init(wrappedValue: .none)
		}
	}
}

extension LossyAutoTypeCodable: Equatable where T: Equatable {
	/// Returns `true` if both wrappers contain equal values.
	public static func == (lhs: LossyAutoTypeCodable<T>, rhs: LossyAutoTypeCodable<T>) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
}

extension LossyAutoTypeCodable: Hashable where T: Hashable {
	/// Hashes the wrapped value into the provided hasher.
	/// - Parameter hasher: The hasher to use when combining the components of this instance.
	public func hash(into hasher: inout Hasher) {
		hasher.combine(wrappedValue)
	}
}

extension LossyAutoTypeCodable: Sendable where T: Sendable { }
