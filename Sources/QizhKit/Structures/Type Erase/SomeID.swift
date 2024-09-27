//
//  SomeID.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.05.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

public enum SomeID: Hashable, Sendable {
	case int(_ value: Int)
	case uint(_ value: UInt)
	case string(_ value: String)
	case uuid(_ value: UUID)
	
	public static var uuid: SomeID {
		.uuid(.init())
	}
	
	@inlinable
	public init(_ value: Int?) {
		self = value.map(Self.int) ?? .unknown
	}
	
	@inlinable
	public init(_ value: UInt?) {
		self = value.map(Self.uint) ?? .unknown
	}
	
	@inlinable
	public init(_ value: String?) {
		self = value.map(Self.string) ?? .unknown
	}
	
	@inlinable
	public init(_ value: Substring?) {
		self.init(value?.asString())
	}
	
	@inlinable
	public init(_ value: UUID?) {
		self = value.map(Self.uuid) ?? .unknown
	}
	
	@inlinable
	public static func some(_ value: Int?) -> SomeID {
		.init(value)
	}
	
	@inlinable
	public static func some(_ value: UInt?) -> SomeID {
		.init(value)
	}
	
	@inlinable
	public static func some(_ value: String?) -> SomeID {
		.init(value)
	}
	
	@inlinable
	public static func some(_ value: Substring?) -> SomeID {
		.init(value)
	}
	
	@inlinable
	public static func some(_ value: UUID?) -> SomeID {
		.init(value)
	}
	
	@inlinable public static func some(_ url: URL?) -> SomeID {
		.init(url?.absoluteString)
	}
	
	/// Returns `.zero` value in `.int` case. Same as `SomeID.zero`
	/// - Returns: `.int(.zero)`
	// public static let none: SomeID = .int(.zero)
	
	/// Returns `.zero` value in `.int` case. Same as `SomeID.none`
	public static let zero: SomeID = .int(.zero)
	@inlinable public var isZero: Bool { self == .zero }
	@inlinable public var isNotZero: Bool { !isZero }
	public var nonZero: SomeID? { isZero ? nil : self }
	
	public var int: Int {
		switch self {
		case .int(let value): return value
		case .uint(let value): return Int(value)
		case .string(let value): return Int(value) ?? .zero
		case .uuid(_): return .zero
		}
	}
	
	public var uint: UInt {
		switch self {
		case .int(let value): return UInt(value)
		case .uint(let value): return value
		case .string(let value): return UInt(value) ?? .zero
		case .uuid(_): return .zero
		}
	}
	
	public var string: String {
		switch self {
		case .int(let value): return value.isZero ? .empty : String(value)
		case .uint(let value): return value.isZero ? .empty : String(value)
		case .string(let value): return value
		case .uuid(let value): return value.uuidString
		}
	}
	
	public var uuid: UUID {
		switch self {
		case .int(_): return UUID()
		case .uint(_): return UUID()
		case .string(_): return UUID()
		case .uuid(let value): return value
		}
	}
	
	public var isSet: Bool {
		switch self {
		case .int(let value): return value.isNotZero
		case .uint(let value): return value.isNotZero
		case .string(let value): return value.isNotEmpty
		case .uuid(_): return true
		}
	}
	
	public var isNotSet: Bool {
		switch self {
		case .int(let value): return value.isZero
		case .uint(let value): return value.isZero
		case .string(let value): return value.isEmpty
		case .uuid(_): return false
		}
	}
	
	public var defined: SomeID? {
		isSet ? self : nil
	}
	
	@inlinable
	public static func == (lhs: SomeID, rhs: Int) -> Bool {
		lhs.int == rhs
	}
	
	@inlinable
	public static func == (lhs: SomeID, rhs: UInt) -> Bool {
		lhs.int == rhs
	}
	
	@inlinable
	public static func == (lhs: SomeID, rhs: String) -> Bool {
		lhs.string == rhs
	}
	
	@inlinable
	public static func == (lhs: SomeID, rhs: UUID) -> Bool {
		lhs.uuid == rhs
	}
	
	@inlinable
	public static func == (lhs: SomeID, rhs: SomeID) -> Bool {
		lhs.string == rhs.string
	}
}

// MARK: ┣ Adopt

extension SomeID: WithUnknown {
	public static let unknown: SomeID = .zero
}

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

extension SomeID: CustomStringConvertible {
	public var description: String {
		string
	}
}

// MARK: Codable

extension SomeID: Codable {
	public init(from decoder: Decoder) throws {
		var container: SingleValueDecodingContainer
		do {
			container = try decoder.singleValueContainer()
		} catch {
			self = .uuid
			return
		}
		
		if let value = try? container.decode(String.self) {
			self = .string(value)
		} else if let value = try? container.decode(UInt.self) {
			self = .uint(value)
		} else if let value = try? container.decode(Int.self) {
			self = .int(value)
		} else {
			self = .uuid
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		switch self {
		case .int(let value): 		try value.encode(to: encoder)
		case .uint(let value): 		try value.encode(to: encoder)
		case .string(let value): 	try value.encode(to: encoder)
		case .uuid(let value): 		try value.encode(to: encoder)
		}
	}
}

public extension KeyedDecodingContainerProtocol {
	func decode(_ type: SomeID.Type, forKey key: Self.Key) -> SomeID {
		(try? decodeIfPresent(SomeID.self, forKey: key)) ?? .uuid
	}
}
