//
//  SomeID.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.05.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import QizhMacroKit

@IsCase @CaseName
public enum SomeID: Hashable, Sendable {
	case int(_ value: Int)
	case uint(_ value: UInt)
	case string(_ value: String)
	case uuid(_ value: UUID)
	case url(_ url: URL)
	
	@inlinable public static var uuid: SomeID {
		.uuid(.init())
	}
	
	// MARK: ┣ init
	
	@inlinable public init(_ value: Int?) {
		if let value {
			self = .int(value)
		} else {
			self = .unknown
		}
	}
	
	@inlinable public init(_ value: UInt?) {
		if let value {
			self = .uint(value)
		} else {
			self = .unknown
		}
	}
	
	@inlinable public init(_ value: Substring?) {
		self.init(value?.asString())
	}
	
	@inlinable public init(_ value: String?) {
		if let value {
			self = .string(value)
		} else {
			self = .unknown
		}
	}
	
	@inlinable public init(_ value: UUID?) {
		if let value {
			self = .uuid(value)
		} else {
			self = .unknown
		}
	}
	
	@inlinable public init(_ value: URL?) {
		if let value {
			self = .url(value)
		} else {
			self = .unknown
		}
	}
	
	// MARK: ┣ some
	
	@inlinable public static func some(_ value: Int?) -> SomeID {
		.init(value)
	}
	
	@inlinable public static func some(_ value: UInt?) -> SomeID {
		.init(value)
	}
	
	@inlinable public static func some(_ value: String?) -> SomeID {
		.init(value)
	}
	
	@inlinable public static func some(_ value: Substring?) -> SomeID {
		.init(value)
	}
	
	@inlinable public static func some(_ value: UUID?) -> SomeID {
		.init(value)
	}
	
	@inlinable public static func some(_ url: URL?) -> SomeID {
		.init(url)
	}
	
	// MARK: ┣ zero
	
	/// Returns `.zero` value in `.int` case. Same as `SomeID.zero`
	/// - Returns: `.int(.zero)`
	// public static let none: SomeID = .int(.zero)
	
	/// Returns `.zero` value in `.int` case. Same as `SomeID.none`
	public static let zero: SomeID = .int(.zero)
	@inlinable public var isZero: Bool { self == .zero }
	@inlinable public var isNotZero: Bool { !isZero }
	public var nonZero: SomeID? { isZero ? nil : self }
	
	// MARK: ┣ Values
	
	public var int: Int {
		switch self {
		case .int(let value): 		value
		case .uint(let value): 		Int(value)
		case .string(let value): 	Int(value) ?? .zero
		case .url(let value): 		Int(value.absoluteString) ?? .zero
		case .uuid: 				.zero
		}
	}
	
	public var uint: UInt {
		switch self {
		case .int(let value): 		UInt(value)
		case .uint(let value): 		value
		case .string(let value): 	UInt(value) ?? .zero
		case .url(let value): 		UInt(value.absoluteString) ?? .zero
		case .uuid: 				.zero
		}
	}
	
	public var string: String {
		switch self {
		case .int(let value): 		value.isZero ? .empty : String(value)
		case .uint(let value): 		value.isZero ? .empty : String(value)
		case .string(let value): 	value
		case .url(let value): 		value.absoluteString
		case .uuid(let value): 		value.uuidString
		}
	}
	
	public var url: URL? {
		switch self {
		case .int: 					.none
		case .uint: 				.none
		case .string(let value): 	URL(string: value)
		case .url(let value): 		value
		case .uuid: 				.none
		}
	}
	
	public var uuid: UUID {
		switch self {
		case .int: 					UUID()
		case .uint: 				UUID()
		case .string: 				UUID()
		case .url: 					UUID()
		case .uuid(let value): 		value
		}
	}
	
	public var isSet: Bool {
		switch self {
		case .int(let value): 		value.isNotZero
		case .uint(let value): 		value.isNotZero
		case .string(let value): 	value.isNotEmpty
		case .url(let value): 		value.absoluteString.isNotEmpty
		case .uuid: 				true
		}
	}
	
	public var isNotSet: Bool {
		switch self {
		case .int(let value): 		value.isZero
		case .uint(let value): 		value.isZero
		case .string(let value): 	value.isEmpty
		case .url(let value): 		value.absoluteString.isEmpty
		case .uuid: 				false
		}
	}
	
	// MARK: ┣ defined
	
	public var defined: SomeID? {
		isSet ? self : nil
	}
}

// MARK: Adopt



// MARK: ┣ +

extension SomeID {
	@inlinable public static func + <RHS> (lhs: Self, rhs: RHS) -> Self
		where RHS: Identifiable,
			  RHS.ID: StringProtocol
	{
		.init("\(lhs)-\(rhs.id)")
	}
	
	@inlinable public static func + <RHS> (lhs: Self, rhs: RHS) -> Self
		where RHS: Identifiable,
			  RHS.ID: BinaryInteger
	{
		.init("\(lhs)-\(rhs.id)")
	}
	
	@inlinable public static func + <RHS> (lhs: Self, rhs: RHS) -> Self
		where RHS: Identifiable,
			  RHS.ID: CustomStringConvertible
	{
		.init("\(lhs)-\(rhs.id)")
	}
	
	@_disfavoredOverload
	@inlinable public static func + (lhs: Self, rhs: CustomStringConvertible) -> Self {
		.init("\(lhs)-\(rhs)")
	}
	
	@_disfavoredOverload
	@inlinable public static func + (lhs: Self, rhs: any BinaryInteger) -> Self {
		.init("\(lhs)-\(rhs)")
	}
	
	@_disfavoredOverload
	@inlinable public static func + (lhs: Self, rhs: any StringProtocol) -> Self {
		.init("\(lhs)-\(rhs)")
	}
	
	@_disfavoredOverload
	@inlinable public static func + (lhs: Self, rhs: any RawRepresentable) -> Self {
		.init("\(lhs)-\(rhs.rawValue)")
	}
}

// MARK: ┣ Equatable

extension SomeID: Equatable {
	@inlinable public static func == (lhs: SomeID, rhs: Int) -> Bool {
		lhs.int == rhs
	}
	
	@inlinable public static func == (lhs: SomeID, rhs: UInt) -> Bool {
		lhs.int == rhs
	}
	
	/*
	@inlinable public static func == (lhs: SomeID, rhs: String) -> Bool {
		lhs.string == rhs
	}
	*/
	
	@inlinable public static func == (lhs: SomeID, rhs: UUID) -> Bool {
		lhs.uuid == rhs
	}
	
	@inlinable public static func == (lhs: SomeID, rhs: URL) -> Bool {
		lhs.url == rhs
	}
	
	@inlinable public static func == (lhs: SomeID, rhs: SomeID) -> Bool {
		lhs.string == rhs.string
	}
	
	@inlinable public static func == (lhs: SomeID, rhs: any StringProtocol) -> Bool {
		lhs.string == rhs
	}
}

// MARK: ┣ Unknown

extension SomeID: WithUnknown {
	public static let unknown: SomeID = .zero
}

// MARK: ┣ Expressible by

extension SomeID: ExpressibleByStringLiteral,
				  ExpressibleByStringInterpolation {
	public init(stringLiteral value: String) {
		self.init(value)
	}
}

extension SomeID: ExpressibleByIntegerLiteral {
	public init(integerLiteral value: IntegerLiteralType) {
		self.init(value)
	}
}

// MARK: ┣ description

extension SomeID: CustomStringConvertible {
	public var description: String {
		switch self {
		case .url(let url) where url.host == "images.unsplash.com"
			&& url.pathComponents.first.orEmpty.hasPrefix("photo-"):
						"unsplash_\(url.pathComponents[0])"
		case .int,
			 .uint,
			 .string,
			 .uuid,
			 .url: 		string.nonEmpty.orXmarkString
		}
	}
}

// MARK: ┗ Codable

extension SomeID: Codable {
	/// Initializes a new instance of `SomeID` by decoding from the given decoder.
	///
	/// Attempts to decode a single value from the decoder. The following decoding
	/// order and logic is used:
	///  - If the container contains a `String`, and it can be parsed as a `URL`, 
	///    initializes as `.url(url)`. Otherwise, initializes as `.string(value)`.
	///  - If the container contains a `UInt`, initializes as `.uint(value)`.
	///  - If the container contains an `Int`, initializes as `.int(value)`.
	///  - If all decoding attempts fail, initializes as `.uuid` using a new UUID.
	///
	/// - Parameter decoder: The decoder to read data from.
	/// - Throws: An error if reading from the decoder fails before reaching a fallback case.
	public init(from decoder: Decoder) throws {
		var container: SingleValueDecodingContainer
		do {
			container = try decoder.singleValueContainer()
		} catch {
			self = .uuid
			return
		}
		
		if let value = try? container.decode(String.self) {
			if let url = URL(string: value) {
				self = .url(url)
			} else {
				self = .string(value)
			}
		} else if let value = try? container.decode(UInt.self) {
			self = .uint(value)
		} else if let value = try? container.decode(Int.self) {
			self = .int(value)
		} else {
			self = .uuid
		}
	}
	
	/// Encodes this `SomeID` value into the given encoder.
	///
	/// Encodes the associated value based on the case of `SomeID`:
	/// - For `.int`, encodes the `Int` value.
	/// - For `.uint`, encodes the `UInt` value.
	/// - For `.string`, encodes the `String` value.
	/// - For `.uuid`, encodes the `UUID` value.
	/// - For `.url`, encodes the `URL` value.
	///
	/// - Parameter encoder: The encoder to write data to.
	/// - Throws: An error if any value fails to encode.
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		
		switch self {
		case .int(let value): 		try container.encode(value)
		case .uint(let value): 		try container.encode(value)
		case .string(let value): 	try container.encode(value)
		case .uuid(let value): 		try container.encode(value)
		case .url(let value): 		try container.encode(value)
		}
	}
}

public extension KeyedDecodingContainerProtocol {
	func decode(_ type: SomeID.Type, forKey key: Self.Key) -> SomeID {
		(try? decodeIfPresent(SomeID.self, forKey: key)) ?? .uuid
	}
}
