//
//  AirtableFormulaBuilder.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public indirect enum AirtableFormulaBuilder: CustomStringConvertible {
	case    search(_ value: String, _ key: String)
	case    equals(_ value: String, _ key: String)
	case notEquals(_ value: String, _ key: String)
	case isEmpty(_ key: String)
	case id(_ value: String)
	case not(_ f: AirtableFormulaBuilder)
	case and(_ a: [AirtableFormulaBuilder])
	case  or(_ a: [AirtableFormulaBuilder])

	@inlinable public static func search(_ value: String, in key: CodingKey) -> AirtableFormulaBuilder {
		.search(value, key.stringValue)
	}
	@inlinable public static func equals(_ value: String, in key: CodingKey) -> AirtableFormulaBuilder {
		.equals(value, key.stringValue)
	}
	@inlinable public static func notEquals(_ value: String, in key: CodingKey) -> AirtableFormulaBuilder {
		.notEquals(value, key.stringValue)
	}
	@inlinable public static func isEmpty(_ key: CodingKey) -> AirtableFormulaBuilder {
		.isEmpty(key.stringValue)
	}
	@inlinable public static func isNotEmpty(_ key: String) -> AirtableFormulaBuilder {
		.not(.isEmpty(key))
	}
	@inlinable public static func isNotEmpty(_ key: CodingKey) -> AirtableFormulaBuilder {
		.not(.isEmpty(key.stringValue))
	}
	@inlinable public static func and(_ items: AirtableFormulaBuilder ...) -> AirtableFormulaBuilder {
		.and(items)
	}
	@inlinable public static func or(_ items: AirtableFormulaBuilder ...) -> AirtableFormulaBuilder {
		.or(items)
	}
	@inlinable public static func ids(_ items: [String]) -> AirtableFormulaBuilder {
		.or(items.map(Self.id))
	}
	
	@inlinable public var  not: AirtableFormulaBuilder { .not(self) }
	@inlinable public func and(_ other: AirtableFormulaBuilder) -> AirtableFormulaBuilder { .and(self, other) }
	@inlinable public func  or(_ other: AirtableFormulaBuilder) -> AirtableFormulaBuilder {  .or(self, other) }
	
	public var description: String {
		switch self {
		case    .search(let v, let k): return "SEARCH('\(e: v)', {\(k)})"
		case    .equals(let v, let k): return "{\(k)} = '\(e: v)'"
		case .notEquals(let v, let k): return "{\(k)} != '\(e: v)'"
		case   .isEmpty(let k): 	   return "{\(k)} = BLANK()"
		case        .id(let v): 	   return "RECORD_ID() = '\(v)'"
		case       .not(let f): 	   return "NOT(\(f))"
		case       .and(let a):        return "AND(\(a.map(\.description).joined(separator: ", ")))"
		case        .or(let a):        return "OR(\(a.map(\.description).joined(separator: ", ")))"
		}
	}
}

// MARK: Interpolate

public extension String.StringInterpolation {
	mutating func appendInterpolation(_ formula: AirtableFormulaBuilder) {
		appendInterpolation(formula.description)
	}
}

// MARK: Escaping Apostrophes

public extension String {
	@inlinable var withApostrophesEscaped: String {
		replacingOccurrences(of: "'", with: "\\'")
	}
}

extension String.StringInterpolation {
	/// Escape single quotes.
	/// ~~~
	/// ' -> \'
	/// ~~~
	mutating func appendInterpolation<Input>(e input: Input)
		where Input: CustomStringConvertible
	{
		appendInterpolation("\(input)".withApostrophesEscaped)
	}
	
	/// Escape single quotes.
	/// ~~~
	/// ' -> \'
	/// ~~~
	mutating func appendInterpolation<Input>(e input: Input)
		where
		Input: RawRepresentable,
		Input.RawValue == String
	{
		appendInterpolation(input.rawValue.withApostrophesEscaped)
	}
}
