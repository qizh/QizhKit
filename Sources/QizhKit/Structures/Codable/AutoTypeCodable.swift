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
			
			func decode <T: LosslessStringCodable> (
				_: T.Type
			) -> (Decoder) -> LosslessStringCodable? {
				{
					try? T.init(from: $0)
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
				decode(Int8.self),
				decode(Int16.self),
				decode(Int64.self),
				decode(UInt.self),
				decode(UInt8.self),
				decode(UInt16.self),
				decode(UInt64.self),
				decode(Double.self),
				decode(Float.self),
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

extension Optional: CustomStringConvertible where Wrapped: LosslessStringConvertible { }
extension Optional: LosslessStringConvertible where Wrapped: LosslessStringConvertible {
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

extension AutoTypeCodable: WithAnyDefault where T: WithDefault { }
extension AutoTypeCodable: WithDefault where T: WithDefault {
	public init() {
		self.init(wrappedValue: .default)
	}
	
	public static var `default`: AutoTypeCodable<T> {
		.init()
	}
}

extension AutoTypeCodable: WithAnyUnknown where T: WithUnknown { }
extension AutoTypeCodable: WithUnknown where T: WithUnknown {
	public init() {
		self.init(wrappedValue: .unknown)
	}
	
	public static var unknown: AutoTypeCodable<T> {
		.init()
	}
}

extension AutoTypeCodable: AnyEmptyProvidable where T: EmptyProvidable { }
extension AutoTypeCodable: EmptyProvidable where T: EmptyProvidable {
	public init() {
		self.init(wrappedValue: .empty)
	}
	
	public static var empty: AutoTypeCodable<T> {
		.init()
	}
}
