//
//  AnyEncodable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 11.03.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import CoreGraphics

@frozen
@propertyWrapper
public struct AnyEncodable: Encodable {
	public var wrappedValue: Any
	
	public init(wrappedValue: Any) {
		self.wrappedValue = wrappedValue
	}
	
	public init<T>(_ value: T?) {
		self.wrappedValue = value ?? ()
	}
	
	@inlinable
	public static func some<T>(_ value: T?) -> Self {
		.init(value)
	}
	
	public static let skipNilValues = CodingUserInfoKey(rawValue: "skip nil encoding")!
}

@usableFromInline
internal protocol AnyEncodableProtocol {
	var wrappedValue: Any { get }
	init<T>(_ value: T?)
}

extension AnyEncodable: AnyEncodableProtocol {}

extension AnyEncodableProtocol {
	public func encode(to encoder: Encoder) throws {
		var container = encoder.singleValueContainer()
		
		switch wrappedValue {
		case is NSNull:
			if encoder.userInfo[AnyEncodable.skipNilValues] as? Bool != true {
				try container.encodeNil()
			}
		case is Void:
			if encoder.userInfo[AnyEncodable.skipNilValues] as? Bool != true {
				try container.encodeNil()
			}
		case let bool as Bool:
			// print("::encoding as Bool: \(bool)")
			try container.encode(bool)
		case let decimal as Decimal:
			// print("::encoding as Decimal: \(decimal)")
			try container.encode(decimal)
		case let int as Int:
			// print("::encoding as Int: \(int)")
			try container.encode(int)
		case let int8 as Int8:
			// print("::encoding as Int8: \(int8)")
			try container.encode(int8)
		case let int16 as Int16:
			// print("::encoding as Int16: \(int16)")
			try container.encode(int16)
		case let int32 as Int32:
			// print("::encoding as Int32: \(int32)")
			try container.encode(int32)
		case let int64 as Int64:
			// print("::encoding as Int64: \(int64)")
			try container.encode(int64)
		case let uint as UInt:
			// print("::encoding as UInt: \(uint)")
			try container.encode(uint)
		case let uint8 as UInt8:
			// print("::encoding as UInt8: \(uint8)")
			try container.encode(uint8)
		case let uint16 as UInt16:
			// print("::encoding as UInt16: \(uint16)")
			try container.encode(uint16)
		case let uint32 as UInt32:
			// print("::encoding as UInt32: \(uint32)")
			try container.encode(uint32)
		case let uint64 as UInt64:
			// print("::encoding as UInt64: \(uint64)")
			try container.encode(uint64)
		case let float as Float:
			// print("::encoding as Float: \(float)")
			try container.encode(float)
		case let double as Double:
			// print("::encoding as Double: \(double)")
			try container.encode(double)
		case let double as CGFloat:
			// print("::encoding as CGFloat: \(double)")
			try container.encode(double)
		case let number as NSNumber:
			// print("::encoding as NSNumber: \(number)")
			try encode(nsnumber: number, into: &container)
		case let string as String:
			// print("::encoding as String: \(string)")
			try container.encode(string)
		case let date as Date:
			// print("::encoding as Date: \(date)")
			try container.encode(date)
		case let url as URL:
			// print("::encoding as URL: \(url)")
			try container.encode(url)
		case let array as [Any?]:
			// print("::encoding as [Any?]: \(array)")
			try container.encode(array.map { AnyEncodable($0) })
		case let dictionary as [String: Any?]:
			// print("::encoding as [String: Any?]: \(dictionary)")
			try container.encode(dictionary.mapValues { AnyEncodable($0) })
		case let encodable as Encodable:
			// print("::encoding as Encodable: \(encodable)")
			try encodable.encode(to: encoder)
		case let optional as Optional<Any>:
			switch optional {
			case .none:
				if encoder.userInfo[AnyEncodable.skipNilValues] as? Bool != true {
					try container.encodeNil()
				}
			case .some(let value):
				try AnyEncodable(value).encode(to: encoder)
			}
		default:
			let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "AnyEncodable value cannot be encoded")
			throw EncodingError.invalidValue(wrappedValue, context)
		}
	}
	
	private func encode(nsnumber: NSNumber, into container: inout SingleValueEncodingContainer) throws {
		switch CFNumberGetType(nsnumber) {
		case .charType:
			try container.encode(nsnumber.boolValue)
		case .sInt8Type:
			try container.encode(nsnumber.int8Value)
		case .sInt16Type:
			try container.encode(nsnumber.int16Value)
		case .sInt32Type:
			try container.encode(nsnumber.int32Value)
		case .sInt64Type:
			try container.encode(nsnumber.int64Value)
		case .shortType:
			try container.encode(nsnumber.uint16Value)
		case .longType:
			try container.encode(nsnumber.uint32Value)
		case .longLongType:
			try container.encode(nsnumber.uint64Value)
		case .intType, .nsIntegerType, .cfIndexType:
			try container.encode(nsnumber.intValue)
		case .floatType, .float32Type:
			try container.encode(nsnumber.floatValue)
		case .doubleType, .float64Type, .cgFloatType:
			try container.encode(nsnumber.doubleValue)
		@unknown default:
			let context = EncodingError.Context(codingPath: container.codingPath, debugDescription: "NSNumber cannot be encoded because its type is not handled")
			throw EncodingError.invalidValue(nsnumber, context)
		}
	}
}

extension AnyEncodable: Equatable {
	public static func == (lhs: AnyEncodable, rhs: AnyEncodable) -> Bool {
		switch (lhs.wrappedValue, rhs.wrappedValue) {
		case is (Void, Void):
			return true
		case let (lhs as Bool, rhs as Bool):
			return lhs == rhs
		case let (lhs as Int, rhs as Int):
			return lhs == rhs
		case let (lhs as Int8, rhs as Int8):
			return lhs == rhs
		case let (lhs as Int16, rhs as Int16):
			return lhs == rhs
		case let (lhs as Int32, rhs as Int32):
			return lhs == rhs
		case let (lhs as Int64, rhs as Int64):
			return lhs == rhs
		case let (lhs as UInt, rhs as UInt):
			return lhs == rhs
		case let (lhs as UInt8, rhs as UInt8):
			return lhs == rhs
		case let (lhs as UInt16, rhs as UInt16):
			return lhs == rhs
		case let (lhs as UInt32, rhs as UInt32):
			return lhs == rhs
		case let (lhs as UInt64, rhs as UInt64):
			return lhs == rhs
		case let (lhs as Float, rhs as Float):
			return lhs == rhs
		case let (lhs as Double, rhs as Double):
			return lhs == rhs
		case let (lhs as CGFloat, rhs as CGFloat):
			return lhs == rhs
		case let (lhs as Decimal, rhs as Decimal):
			return lhs == rhs
		case let (lhs as String, rhs as String):
			return lhs == rhs
		case let (lhs as [String: AnyEncodable], rhs as [String: AnyEncodable]):
			return lhs == rhs
		case let (lhs as [AnyEncodable], rhs as [AnyEncodable]):
			return lhs == rhs
		default:
			return false
		}
	}
}

extension AnyEncodable: CustomStringConvertible {
	public var description: String {
		switch wrappedValue {
		case is Void:
			return String(describing: nil as Any?)
		case let value as CustomStringConvertible:
			return value.description
		default:
			return String(describing: wrappedValue)
		}
	}
}

extension AnyEncodable: CustomDebugStringConvertible {
	public var debugDescription: String {
		switch wrappedValue {
		case let value as CustomDebugStringConvertible:
			return "AnyEncodable(\(value.debugDescription))"
		default:
			return "AnyEncodable(\(description))"
		}
	}
}

extension AnyEncodable: ExpressibleByNilLiteral {}
extension AnyEncodable: ExpressibleByBooleanLiteral {}
extension AnyEncodable: ExpressibleByIntegerLiteral {}
extension AnyEncodable: ExpressibleByFloatLiteral {}
extension AnyEncodable: ExpressibleByStringLiteral {}
extension AnyEncodable: ExpressibleByStringInterpolation {}
extension AnyEncodable: ExpressibleByArrayLiteral {}
extension AnyEncodable: ExpressibleByDictionaryLiteral {}

extension AnyEncodableProtocol {
	public init(nilLiteral _: ()) {
		self.init(nil as Any?)
	}

	public init(booleanLiteral value: Bool) {
		self.init(value)
	}

	public init(integerLiteral value: Int) {
		self.init(value)
	}

	public init(floatLiteral value: Double) {
		self.init(value)
	}

	public init(extendedGraphemeClusterLiteral value: String) {
		self.init(value)
	}

	public init(stringLiteral value: String) {
		self.init(value)
	}

	public init(arrayLiteral elements: Any...) {
		self.init(elements)
	}

	public init(dictionaryLiteral elements: (AnyHashable, Any)...) {
		self.init([AnyHashable: Any](elements, uniquingKeysWith: { first, _ in first }))
	}
}
