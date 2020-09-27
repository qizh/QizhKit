//
//  CaseNameProvidable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public protocol CaseNameProvidable {
	var caseName: String { get }
}

public extension CaseNameProvidable {
	/// Raw, use to compare
	@inlinable var caseName: String {
		QizhKit.caseName(of: self, .raw)
	}
	
	@inlinable var caseWord: String {
		QizhKit.caseName(of: self, .name)
	}
}

public extension CaseNameProvidable where Self: Identifiable {
	@inlinable var id: String { caseName }
}

public protocol CaseByNameProvidable: CaseNameProvidable, CaseIterable, ExpressibleByStringLiteral { }
public protocol CaseByRawValueProvidable: RawRepresentable, ExpressibleByStringLiteral { }

public extension CaseNameProvidable
	where
	Self: CaseIterable,
	Self: ExpressibleByStringLiteral
{
	init(stringLiteral name: String) {
		let result = Self.allCases
			.first(where: \.caseWord, equals: name)
		
		switch result {
		case .some(let value): self = value
		case .none:
			print("You're trying to compare to `\(Self.self).\(name)` which does not exist.")
			
			let similar = Self.allCases
				.map(\.caseName)
				.closest(
					to: name,
					using: \.damerauLevenshteinDistance
				)
			
			let similarCase = similar.flatMap { name -> Self? in
				print("Trying to use similar case `\(Self.self).\(name)`.")
				return Self.allCases
					.first(where: \.caseWord, equals: name)
			}
			
			switch similarCase {
			case .some(let value): self = value
			case .none:
				fatalError("No luck.")
			}
		}
	}
}

public extension ExpressibleByStringLiteral where Self: RawRepresentable {
	init(stringLiteral value: RawValue) {
		self = Self(rawValue: value)
			.forceUnwrap(because: "A user is using a valid string")
	}
}

// MARK: Case Name

@inlinable public func caseName(mirror option: Any) -> String? {
	Mirror(reflecting: option).children.first?.label
}

@inlinable public func caseName(reflect option: Any) -> String {
	String(reflecting: option)
}

@inlinable public func caseName(describe option: Any) -> String {
	String(describing: option)
}

@inlinable public func caseName(of option: Any) -> String {
	caseName(of: option, .raw)
}

@inlinable public func caseName(of option: Any, _ format: CaseNameFormat) -> String {
	format.apply(on: String(reflecting: option))
}

public struct CaseNameFormat: OptionSet, ExpressibleByIntegerLiteral {
	public let rawValue: Int
	public init(rawValue: RawValue) {
		self.rawValue = rawValue
	}
	
	public init(integerLiteral value: Int) {
		self.init(rawValue: 1 << value)
	}
	
	public static let raw: 			CaseNameFormat = 0
	public static let parent: 		CaseNameFormat = 1
	public static let type: 		CaseNameFormat = 2
	public static let name: 		CaseNameFormat = 3
	public static let arguments: 	CaseNameFormat = 4
	
	/// Minimum required data for output to be unique
	public static let identifiable: CaseNameFormat = [.name, .arguments]
	/// A bit more data then minimally required: struct name added
	public static let debugable: 	CaseNameFormat = [.type, .name, .arguments]
	public static let typeInParent: CaseNameFormat = [.parent, .type]
	public static let full: 		CaseNameFormat = [.parent, .type, .name, .arguments]
	
	public func apply(on input: String) -> String {
		if self == .raw {
			return input
		}
		
		let package = input.take(all: .ending(with: .first, .dot))
		
		var arguments = input
			.take(all: .starting(with: .first, .leftSkobka))
		if arguments.isNotEmpty && arguments.contains(.dotChar) {
			if arguments.contains(.spaceChar) {
				/// Multiple arguments
				arguments = arguments.replacing(package)
			} else {
				/// One argument
				let argumentType = arguments
					.deleting(prefix: .leftSkobka)
					.deleting(suffix: .rightSkobka)
				arguments = .leftSkobka + apply(on: argumentType) + .rightSkobka
			}
		}
		
		let name = input
			.deleting(.starting(with: .first, .leftSkobka))
			.take(all: .after(.last, .dot))
		
		let type = input
			.deleting(.starting(with: .first, name))
			.take(all: .after(.last, .dot))
		
		let parent = input
			.deleting(.starting(with: .first, type))
			.take(all: .after(.last, .dot))
		
		var output: String = .empty
		
		if contains(.parent) {
			output += parent
		}
		
		if contains(.type) {
			if output.isNotEmpty {
				output += .dot
			}
			output += type
		}
		
		if contains(.name) {
			if output.isNotEmpty {
				output += .dot
			}
			output += name
		}
		
		if contains(.arguments) {
			output += arguments
		}
		
		return output
	}
}
