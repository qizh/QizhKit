//
//  CodableField.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Generic

public struct GenericType: CustomStringConvertible, Sendable, Updatable {
	private(set) public var     name:  String
	public let                  path: [String]
	public let              children: [GenericType]
	public let                source:  Source
	private(set) public var   inline:  InlineType = .default
	
	// MARK: 1. Parse
	
	public static func parsing(string source: String) -> GenericType {
		let startAnchor: String.Anchor = .starting(with: .first, "<")
		let components = source
			.deleting(startAnchor)
			.components(separatedBy: String.dot)
		
		let generics = source
			.matching(startAnchor)
			.nonEmpty.map { match in
				match
					.deleting(prefix: "<")
					.deleting(suffix: ">")
					.components(separatedBy: ", ")
					.map { element in
						let cut = element
							.deleting(prefix: "NS")
							.replacing(".NS", with: .dot)
//						print(.tab * 2 + "... " + element + " -> " + cut)
						return cut
					}
					.map(GenericType.parsing)
			}.orEmpty
		
		
		var result = GenericType(components: components, generics: generics)
//		let resultPrintCopy = result
		if let wrapped = result.children.first {
			let ptype = result.name
			switch ptype {
			case "Optional":    result =  .optional( wrapped)
//				print(.tab + "\(resultPrintCopy) -> \(result)")
			case "Array":       result =  .array(of: wrapped)
//				print(.tab + "\(resultPrintCopy) -> \(result)")
			case "CodeAsArray": result = .array(one: wrapped)
//				print(.tab + "\(resultPrintCopy) -> \(result)")
			case "ExtraCase":   result =        .any(wrapped)
//				print(.tab + "\(resultPrintCopy) -> \(result)")
			default: ()
			}
		}
//		result.name = result.inline.description(for: result.name)
		return result
	}
	
	public static func parsing <T> (_ value: T) -> GenericType {
		.parsing(string: String(reflecting: Swift.type(of: value as Any)))
	}
	
	// MARK: 2. Use
	
	private init(components: [String], generics: [GenericType] = .empty) {
		var source: Source = .unknown
		var path: [String] = .empty
		for element in components {
			if element.hasPrefix("__") || element == "Swift" {
				if source.isUnknown { source = .system }
			} else if ["QizhKit", "BespokelyKit", "Bespokely"].contains(element) {
				if source.isUnknown { source = .user }
			} else {
				if source.isUnknown { source = .framework }
				path.append(element)
			}
		}
		self.name     = path.cutLast().orEmpty
		self.path     = path
		self.source   = source
		self.children = generics
	}
	
	// MARK: 3. Modify
	
	private static func optional(_ item: GenericType) -> GenericType {
		item.updating(\.inline).with { (type: inout InlineType) in
			type.remove(.default)
			if !type.insert(.optionalRoot).inserted {
				type.insert(.optionalLeaf)
			}
		}
	}
	
	private static func array(of item: GenericType) -> GenericType {
		item.updating(\.inline).with { (type: inout InlineType) in
			type.insert(.array)
			if type.remove(.optionalRoot) != nil {
				type.insert(.optionalLeaf)
			}
		}
	}
	
	private static func array(one item: GenericType) -> GenericType {
		item.updating(\.inline).with { (type: inout InlineType) in
			type.insert(.array)
			type.insert(.single)
			if type.remove(.optionalRoot) != nil {
				type.insert(.optionalLeaf)
			}
		}
	}
	
	private static func any(_ item: GenericType) -> GenericType {
		item.updating(\.inline).with { (type: inout InlineType) in
			type.insert(.any)
			if type.remove(.optionalRoot) != nil {
				type.insert(.optionalLeaf)
			}
		}
	}
	
	// MARK: > Output
	
	public var description: String { description() }
	public func description(in level: UInt = .zero, compact: Bool = false) -> String {
		let prefix = String.tab * level
		var output: String = prefix
		if path.isNotEmpty {
			output += path.joined(separator: .dot) + .dot
		}
		output += name
		if let first = children.first {
			let firstDescription = first.description(in: .zero, compact: compact)
			var multiline = not(compact)
			multiline &&= firstDescription.contains(.newLineChar) || children.isNotAlone
			if multiline {
				output += "<" + .newLine
				for generic in children {
					output += generic.description(in: level.next, compact: compact) + .coma + .newLine
				}
				output += .newLine + ">"
			} else {
				output += "<" + first.description(in: .zero, compact: compact) + ">"
			}
		}
		return inline.description(for: output)
	}
	
	// MARK: > Get
	
	public var isOptionalRoot: Bool {
		inline.contains(.optionalRoot)
	}
	
	public var isOptionalLeaf: Bool {
		inline.contains(.optionalLeaf)
	}
	
	public var isArray: Bool {
		inline.contains(.array)
	}
	
	public var isAloneInArray: Bool {
		inline.contains(.single)
	}
	
	public var isAcceptingUnknownValues: Bool {
		inline.contains(.any)
	}
	
	public var descriptive: String {
		description(compact: true)
	}
	
	public var flat: [GenericType] {
		children.flatMap(\.flat).prepending(self)
	}
	
	public var last: GenericType {
		flat.last ?? self
	}
	
	// MARK: > Origin
	
	public enum Source: String, Sendable, WithUnknown, EasyCaseComparable {
		case unknown
		case system
		case user
		case framework
	}
	
	// MARK: > Inline Type
	
	public struct InlineType: OptionSet,
							  Sendable,
							  WithDefault,
							  CustomStringConvertible,
							  ExpressibleByIntegerLiteral
	{
		public let rawValue: Int
		public init(rawValue: RawValue) {
			self.rawValue = rawValue
		}
		public init(integerLiteral value: Int) {
			self.init(rawValue: 1 << value)
		}
		
		public  static let `default`: 	  InlineType = 0
		public  static let  optionalLeaf: InlineType = 1
		public  static let  optionalRoot: InlineType = 2
		public  static let  array: 		  InlineType = 3
		private static let  alone:        InlineType = 4
		public  static let  any:          InlineType = 5

		public static let single: InlineType = [
			.array,
			.alone,
		]
		
		public var description: String {
			var output: [String] = .empty
			if contains(.default)      { output.append("Default") }
			if contains(.optionalLeaf) { output.append("Optional Leaf") }
			if contains(.optionalRoot) { output.append("Optional Root") }
			if contains(.array)        { output.append("Array") }
			if contains(.single)       { output.append("Single Element") }
			return "[" + output.joined(separator: .comaspace) + "]"
		}
		
		public func description(for type: String) -> String {
			var out: String = type
			if contains(.any) 			{ out  = "Any" + out 	}
			if contains(.optionalLeaf) 	{ out += "?" 			}
			if contains(.array) 		{ out  = "[\(out)]" 	}
			if contains(.single) 		{ out += "{1}" 			}
			if contains(.optionalRoot) 	{ out += "?" 			}
			return out
		}
	}
}

// MARK: Field

public struct CodableField: Hashable, Encodable, PrettyStringConvertable {
	public let     variable: String
	public let          key: String
	public let            s: String
	public let            m: String
	public let            l: String
	public let           xl: String
	public let optionalRoot: Bool
	public let optionalLeaf: Bool
	public let        array: Bool
	public let willUseFirst: Bool
	public let      unknown: Bool
	public let   underlying: String
	public let     fallback: String
	public let        known: [String]
	public let    behaviour: UnknownValueFallbackBehaviour
	
	public enum CodingKeys: String, CodingKey, CaseIterable {
		case variable 		= "App Variable Name"
		case key 			= "Data Field Name"
		case s 				= "App Variable Type S"
		case m 				= "App Variable Type M"
		case l 				= "App Variable Type L"
//		case xl 			= "App Variable Type XL"
		case optionalRoot 	= "Is Container Optional"
		case optionalLeaf 	= "Is Element Optional"
		case array 			= "Is Array"
		case willUseFirst 	= "Is Using First Element Only"
		case unknown 	    = "Is Accepting Unknown Value"
		case underlying 	= "Representable Type"
		case fallback 		= "Default Value"
		case known 			= "Known Values"
		case behaviour 		= "Unknown Value Fallback Behaviour"
	}
	
	// MARK: Constructor
	
	public init <Value> (
		label: String,
		  key: String,
		value: Value
	) {
		print(.tab + " field: " + "\(Mirror(reflecting: value).subjectType)")
		
		self.variable = label
		self.key = key
		
		let parsed = GenericType.parsing(value)
		let inner  = parsed.children.first
		let main   = inner ?? parsed
		self.s 	   = main.name
		self.m     = main.descriptive
		self.l     = "\(Mirror(reflecting: value).subjectType)"
		self.xl    = String(reflecting: Swift.type(of: value as Any))
		
		self.optionalRoot 	= main.isOptionalRoot
		self.optionalLeaf 	= main.isOptionalLeaf
		self.array 		  	= main.isArray
		self.willUseFirst 	= main.isAloneInArray
		self.unknown 		= main.isAcceptingUnknownValues
		
		print(.tab + "parsed: " + parsed.description)
		print(.tab + "inline: " + parsed.inline.description)
		
		let meta = SpecialMetadata.for(value, using: parsed)
		self.underlying = meta.raw
		self.fallback 	= meta.default
		self.known 		= meta.known
		self.behaviour 	= meta.unknown
	}
	
	// MARK: Generator
	
	public static func fields <Root, Keys> (for instance: Root, _: Keys.Type) -> [CodableField]
		where
		Keys: CodingKey,
		Keys: CaseIterable
	{
		let labels = casesNames(of: Keys.self)
		let keys = Keys.allCases.map(\.stringValue)
		let children = Mirror(reflecting: instance).children
		print("\(children.count) children: [\n\t\(children.map { "\(map: $0.label?.deleting(prefix: "_")): \t\(Swift.type(of: $0.value))" }.joined(separator: .coma + .newLine + .tab))\n]")
		return zip(labels, keys)
			.compactMap { label, key in
				return children.first { $0.label?.deleting(prefix: "_") == label }
					.map { child in
						print("---[ \(label) | \(key) ]---")
						let field = CodableField(
							label: label,
							  key: key,
							value: child.value
						)
						print("result: \(field)")
						return field
					}
				}
	}
	
	// MARK: Unknown Behaviour
	
	public enum UnknownValueFallbackBehaviour: String,
		EasyCaseComparable,
		WithUnknown,
		Encodable
	{
		case unknown 	= ""
		case irrelevant = "Accepts all values"
		case fallback 	= "Will use default value"
		case use 		= "Will use provided value"
		case useDigits 	= "Will use provided value if it contains digits"
		case error 		= "Will produce an error"
	}
	
	// MARK: Metadata
	
	public struct SpecialMetadata {
		/// Variable representable type
		public private(set) var  raw: String
		
		/// Default value
		public private(set) var `default`: String
		
		/// All values app knows
		public private(set) var  known: [String]
		
		/// Field behaviour when received an unknown value
		public private(set) var  unknown: UnknownValueFallbackBehaviour
		
		public static func `for` <T> (_ value: T, using generic: GenericType) -> Self {
			print(.tab + "> collecting info")
			let unwrapped = unwrap(value, tabs: 2)
			
			let last = generic.last.name
			switch last {
			case "PhoneNumberDigits":
				return .init(
						raw: "String",
					default: .empty,
					  known:  String.numerics.split(by: .one),
					unknown: .useDigits
				)
			case "AirtableImage":
				return .init(
						raw: "Airtable Image Struct",
					default: .empty,
					  known: .empty,
					unknown: .error
				)
			case "ReviewRate":
				return .init(
						raw: "Int",
					default: .empty,
					  known: (1...5).map(\.s),
					unknown: .fallback
				)
			case "DefaultFalse":
				return .init(
						raw: "Bool",
					default: "false",
					  known: ["true", "false"],
					unknown: .fallback
				)
			default: ()
			}
			
			if generic.isAloneInArray {
				print(.tab + "> CodeAsArray")
				if let (_, inner) = Mirror(reflecting: unwrapped).children.first {
					if generic.isAcceptingUnknownValues {
						print(.tab * 2 + "> ExtraCase")
						let innerUnwrapped = unwrap(inner, tabs: 3)
						return .init(
								raw: "String",
							default: Self.def(of: innerUnwrapped).orEmpty,
							  known: Self.val(of: innerUnwrapped),
							unknown: .use
						)
					}
					print(.tab * 2 + "> of \(type(of: inner))")
					let innerUnwrapped = unwrap(inner, tabs: 3)
					return .init(
							raw: Self.raw(of: innerUnwrapped),
						default: Self.def(of: innerUnwrapped).orEmpty,
						  known: Self.val(of: innerUnwrapped),
						unknown: .error
					)
				}
			} else if generic.isAcceptingUnknownValues {
				print(.tab + "ExtraCase")
				return .init(
						raw: "String",
					default: Self.def(of: unwrapped)?.nonEmpty ?? "<empty String>",
					  known: Self.val(of: unwrapped),
					unknown: .use
				)
			}
			
			let name = generic.name
			print(.tab + "name: \(name)")
			switch name {
			case "DefaultZero":
				print(.tab + name)
				if let (_, inner) = Mirror(reflecting: unwrapped).children.first {
					print(.tab * 2 + "> got inner")
					return .init(
							raw: Self.raw(of: inner),
						default: "0",
						  known: Self.val(of: inner),
						unknown: .fallback
					)
				}
			case "DefaultValueOne":
				print(.tab + name)
				if let (_, inner) = Mirror(reflecting: unwrapped).children.first {
					print(.tab * 2 + "> got inner")
					return .init(
							raw: Self.raw(of: inner),
						default: "1",
						  known: Self.val(of: inner),
						unknown: .fallback
					)
				}
			case "DefaultMax":
				print(.tab + name)
				if let (_, inner) = Mirror(reflecting: unwrapped).children.first {
					print(.tab * 2 + "> got inner")
					return .init(
							raw: Self.raw(of: inner),
						default: "<infinity>",
						  known: Self.val(of: inner),
						unknown: .fallback
					)
				}
			case "DefaultEmpty":
				print(.tab + name)
				if let (_, inner) = Mirror(reflecting: unwrapped).children.first {
					print(.tab * 2 + "> got inner")
					let innerUnwrapped = unwrap(inner, tabs: 3)
					let innerGeneric = generic.children.first
					let raw = Self.raw(of: innerUnwrapped)
					return .init(
							raw: raw,
						default: "<empty \(innerGeneric?.isArray == true ? "Array of " : .empty)\(raw)>",
						  known: Self.val(of: inner),
						unknown: .fallback
					)
				}
			case "CustomDate":
				print(.tab + name)
				return .init(
						raw: "String",
					default: .empty,
					  known: [ISO8601DashedDateFormatterProvider.dateFormatter.string(from: .now)],
					unknown: .error
				)
			case "URL":
				print(.tab + name)
				return .init(
						raw: "String",
					default: .empty,
					  known: .empty,
					unknown: .error
				)
			default: ()
			}
			
			return .init(
					raw:  Self.raw(of: unwrapped),
				default:  Self.def(of: unwrapped).orEmpty,
				  known:  Self.val(of: unwrapped),
				unknown: .unknown
			)
		}
		
		private static func unwrap <U> (_ value: U, tabs: UInt) -> Any {
			let prefix: String = .tab * tabs
			print(prefix + "> unwrapping \(type(of: value as Any)) value")
			var unwrapped: Any
			if let optional = value as? OptionalConvertible {
				if optional.isSet {
					unwrapped = optional.anyForceUnwrap(because: "tested")
					print(prefix + "> unwrapped to \(optional.wrappedType)")
				} else if let someRecreated = optional.recreateAny(debug: true, tabs: tabs + 1),
						  let recreated = someRecreated as? OptionalConvertible,
						  recreated.isSet {
					unwrapped = recreated.anyForceUnwrap(because: "recreated")
					print(prefix + "> recreated \(type(of: unwrapped))")
				} else {
					print(prefix + "< cant unwrap or recreate")
					return value
				}
			} else {
				if let array = value as? AnyElementCollection,
				   let optionalFirst = array.anyFirst as? OptionalConvertible {
					print(prefix + "> is array of \(array.elementType)")
					if let someRecreated = optionalFirst.recreateAny(debug: true, tabs: tabs + 1),
					   let recreated = someRecreated as? OptionalConvertible,
					   recreated.isSet
					{
						unwrapped = recreated.anyForceUnwrap(because: "recreated")
						print(prefix + "> recreated \(type(of: unwrapped))")
					} else {
						print(prefix + "< can't unwrap array element")
						return array
					}
				} else {
					print(prefix + "< can't unwrap")
					return value
				}
			}
			return unwrap(unwrapped, tabs: tabs + 1)
		}

		// MARK: Raw Value
		
		private static func raw <R> (of value: R) -> String {
			print(.tab + "raw for \(type(of: value as Any)): ...")
			let unwrapped = value as Any
			
			if let _ = unwrapped as? URL {
				print(.tab * 2 + "< is URL")
				return "String"
			}
			
			if let rep = unwrapped as? StringRepresentable {
				print(.tab * 2 + "< \(rep.representableType) representable")
				return "\(rep.representableType)"
			}
			
			if let iterable = unwrapped as? StringIterable {
				print(.tab * 2 + "> iterable")
				let allStrings = type(of: iterable).allStringRepresentations
				if let first = allStrings.first,
				   first.hasPrefix("<"),
				   first.hasSuffix(">") {
					print(.tab * 3 + "< not raw representable")
					return "<case>"
				}
				
				let withDigitsOnly = allStrings.compactMap { string in
					string.replacing(CharacterSet.decimalDigits, with: .empty).nonEmpty
				}
				if allStrings.isNotEmpty, withDigitsOnly.count < allStrings.count {
					print(.tab * 3 + "< all have digits")
					return "Numeric"
				} else {
					print(.tab * 3 + "< assuming it is String")
					return "String"
				}
			}
			
			print(.tab * 2 + "< nothing special found for \(type(of: unwrapped))")
			return "\(type(of: unwrapped))".deleting(prefix: "NS")
		}
		
		// MARK: Default Value
		
		private static func def <D> (of value: D) -> String? {
			print(.tab + "default for \(type(of: value as Any)): ...")
			
			let unwrapped = value as Any

			switch unwrapped {
			case let recognized as WithAnyDefault:
				print(.tab * 2 + "has default: \(type(of: recognized).anyDefault)")
				return "\(type(of: recognized).anyDefault)"
			case let recognized as WithAnyUnknown:
				print(.tab * 2 + "has unknown: \(type(of: recognized).anyUnknown)")
				return "\(type(of: recognized).anyUnknown)"
			default:
				print(.tab * 2 + "nothing to use")
				return nil
			}
		}
			
		// MARK: Known Values
		
		private static func val <T> (of value: T) -> [String] {
			print(.tab + "known for \(type(of: value as Any)): ...")
			var result: [String] = .empty
			
			let unwrapped = value as Any
	//		let optional = Optional(unwrapped) as Any?
			
			if let iterable = unwrapped as? StringIterable {
				print(.tab * 2 + "has string representations: \(type(of: iterable).allStringRepresentations)")
				result += type(of: iterable).allStringRepresentations
			} else {
				let mirror = Mirror(reflecting: unwrapped)
				if mirror.displayStyle == .enum, mirror.children.isNotEmpty {
					print(.tab * 2 + "using enum reflection")
					for child in mirror.children {
						let childMirror = Mirror(reflecting: child.value)
						if childMirror.displayStyle == .enum, childMirror.children.isNotEmpty {
							for childChild in childMirror.children {
								print(.tab * 3 + (childChild.label ?? "_") + ": \(childChild.value)")
								result.append("\(childChild.value)")
							}
						} else {
							print(.tab * 3 + (child.label ?? "_") + ": \(child.value)")
							result.append("\(child.value)")
						}
					}
				} else {
					print(.tab * 2 + "nothing to use")
				}
			}
			
			return result.filter(\.isNotEmpty).firstUniqueElements
		}
	}

}
