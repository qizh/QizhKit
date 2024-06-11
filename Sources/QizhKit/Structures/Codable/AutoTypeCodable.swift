//
//  AutoTypeCodable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.11.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

@propertyWrapper
public struct AutoTypeCodable <T>: Codable
	where T: LosslessStringConvertible,
		  T: Codable
{
	private typealias LosslessStringCodable = LosslessStringConvertible & Codable
	private let type: LosslessStringCodable.Type
	
	public var wrappedValue: T

	public init(wrappedValue: T) {
		self.wrappedValue = wrappedValue
		self.type = T.self
	}
	
	public init(from decoder: Decoder) throws {
		do {
			self.wrappedValue = try T.init(from: decoder)
			self.type = T.self
		} catch let error {
			
			func decode <D: LosslessStringCodable> (
				_: D.Type
			) -> (Decoder) -> LosslessStringCodable? {
				{
					try? D.init(from: $0)
				}
			}
			
			func decodeBoolFromNSNumber() -> (Decoder) -> LosslessStringCodable? {
				{
					(try? Int.init(from: $0))
						.flatMap {
							Bool(exactly: NSNumber(value: $0))
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
				  let value = T.init("\(rawValue)")
			else { throw error }
			
			self.wrappedValue = value
			self.type = Swift.type(of: rawValue)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		let string = String(describing: wrappedValue)
		
		guard let original = type.init(string) else {
			let description = "Unable to encode `\(wrappedValue)` back to source type `\(type)`"
			throw EncodingError.invalidValue(string, .init(codingPath: [], debugDescription: description))
		}
		
		try original.encode(to: encoder)
	}
}

public extension KeyedDecodingContainer {
	func decode<T>(_: AutoTypeCodable<T>.Type, forKey key: Key) -> AutoTypeCodable<T> where T: TypedOptionalConvertible {
		(try? decodeIfPresent(AutoTypeCodable<T>.self, forKey: key)) ?? AutoTypeCodable<T>(wrappedValue: .none)
	}
}

extension Optional: @retroactive CustomStringConvertible where Wrapped: LosslessStringConvertible { }
extension Optional: @retroactive LosslessStringConvertible where Wrapped: LosslessStringConvertible {
	public init?(_ description: String) {
		self = Wrapped.init(description)
	}
	
	public var description: String {
		switch self {
		case .none: return .empty
		case .some(let value): return value.description
		}
	}
}

extension AutoTypeCodable: Equatable where T: Equatable {
	public static func == (lhs: AutoTypeCodable<T>, rhs: AutoTypeCodable<T>) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
}

extension AutoTypeCodable: Hashable where T: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(wrappedValue)
	}
}

// MARK: Adopt

extension Date: @retroactive LosslessStringConvertible {
	public init?(_ description: String) {
		#if swift(>=5.5)
		if #available(iOS 15.0, *) {
			do {
				try self.init(
					description,
					strategy: Date.ParseStrategy(
						format: "\(day: .twoDigits).\(month: .twoDigits).\(year: .defaultDigits) \(hour: .twoDigits(clock: .twentyFourHour, hourCycle: .zeroBased)):\(minute: .twoDigits)",
						timeZone: .current
					)
				)
			} catch {
				return nil
			}
		} else if let date = DateFormatter().date(from: description) {
			self = date
		} else {
			return nil
		}
		#endif
		if let date = DateFormatter().date(from: description) {
			self = date
		} else {
			return nil
		}
	}
}

extension Decimal: @retroactive LosslessStringConvertible {
	public init?(_ description: String) {
		self.init(string: description)
	}
}

// MARK: - Defaulted

@propertyWrapper
public struct LossyAutoTypeCodable <T>: Codable
	where T: LosslessStringConvertible,
		  T: Codable
{
	private typealias LosslessStringCodable = LosslessStringConvertible & Codable
	private let type: LosslessStringCodable.Type
	
	public var wrappedValue: T
	
	public init(wrappedValue: T) {
		self.wrappedValue = wrappedValue
		self.type = T.self
	}
	
	public init(from decoder: Decoder) throws {
		do {
			self.wrappedValue = try T.init(from: decoder)
			self.type = T.self
		} catch let error {
			
			func decode <D: LosslessStringCodable> (
				_: D.Type
			) -> (Decoder) -> LosslessStringCodable? {
				{
					try? D.init(from: $0)
				}
			}
			
			func decodeBoolFromNSNumber() -> (Decoder) -> LosslessStringCodable? {
				{
					(try? Int.init(from: $0))
						.flatMap {
							Bool(exactly: NSNumber(value: $0))
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
				  let value = T.init("\(rawValue)")
			else { throw error }
			
			self.wrappedValue = value
			self.type = Swift.type(of: rawValue)
		}
	}
	
	public func encode(to encoder: Encoder) throws {
		let string = String(describing: wrappedValue)
		
		guard let original = type.init(string) else {
			let description = "Unable to encode `\(wrappedValue)` back to source type `\(type)`"
			throw EncodingError.invalidValue(string, .init(codingPath: [], debugDescription: description))
		}
		
		try original.encode(to: encoder)
	}
}

public extension KeyedDecodingContainer {
	func decode<T>(_: LossyAutoTypeCodable<T>.Type, forKey key: Key) throws -> LossyAutoTypeCodable<T> {
		if let decoded = try? decodeIfPresent(LossyAutoTypeCodable<T>.self, forKey: key) {
			return decoded
		} else if let defaultValue = T("false") ?? T("0") {
			return .init(wrappedValue: defaultValue)
		} else {
			throw DecodingError.dataCorruptedError(forKey: key, in: self, debugDescription: "Neither can decode \(T.self) value nor create a default one")
		}
	}
	
	/// Optional
	func decode<T>(_: LossyAutoTypeCodable<T>.Type, forKey key: Key) throws -> LossyAutoTypeCodable<T> where T: TypedOptionalConvertible {
		if let decoded = try? decodeIfPresent(LossyAutoTypeCodable<T>.self, forKey: key) {
			return decoded
		} else if let defaultValue = T("false") ?? T("0") {
			return .init(wrappedValue: defaultValue)
		} else {
			return .init(wrappedValue: .none)
		}
	}
}

extension LossyAutoTypeCodable: Equatable where T: Equatable {
	public static func == (lhs: LossyAutoTypeCodable<T>, rhs: LossyAutoTypeCodable<T>) -> Bool {
		lhs.wrappedValue == rhs.wrappedValue
	}
}

extension LossyAutoTypeCodable: Hashable where T: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(wrappedValue)
	}
}
