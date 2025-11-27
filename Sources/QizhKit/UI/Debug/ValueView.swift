//
//  ValueView.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 29.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import QizhMacroKit
import CoreTransferable

#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

@IsCase @CaseName
@MainActor
public enum ValueView: View, Sendable {
	case undefined(NilReplacement)
	case string(String)
	case text(Text)
	case bool(Bool, display: LabeledValueView.BoolDisplayStyle = .icon)
	case integer(any (FixedWidthInteger & SignedInteger))
	case unsignedInteger(any (FixedWidthInteger & UnsignedInteger))
	case floatingPoint(any (BinaryFloatingPoint & CVarArg), fraction: Int = .zero)
	case cgFloat(CGFloat, fraction: Int = .zero)
	case cgPoint(CGPoint, fraction: Int = .zero)
	case cgSize(CGSize, fraction: Int = .zero)
	case cgRect(CGRect, fraction: Int = .zero)
	case cgVector(CGVector, fraction: Int = .zero)
	case edgeInsets(EdgeInsets, fraction: Int = .zero)
	
	public var body: some View {
		text
			.semibold(8)
			.padding(EdgeInsets(top: 3, leading: 5, bottom: 2, trailing: 5))
			.foregroundStyle(.primary)
	}
	
	public var text: Text {
		switch self {
		case let .undefined(value):
			Text(value.description)
		case let .string(string):
			Text(string)
		case let .text(text):
			text
		case let .bool(bool, displayStyle):
			switch displayStyle {
			case .string:
				ValueView.string(bool ? "true" : "false").text
			case .int:
				ValueView.string(bool ? "1" : "0").text
			case .icon:
				Text(Image(systemName: bool ? "checkmark" : "xmark"))
			case .emoji:
				ValueView.string(bool.sign.s).text
			}
		case let .integer(integer):
			Text(Int(integer).formatted(.number))
		case let .unsignedInteger(integer):
			Text(UInt(integer).formatted(.number))
		case let .floatingPoint(value, fraction):
			Text(Double(value).formatted(.number.precision(.fractionLength(fraction))))
		case let .cgFloat(value, fraction):
			Text(Double(value).formatted(.number.precision(.fractionLength(fraction))))
		case let .cgPoint(value, fraction):
				ValueView.cgFloat(value.x, fraction: fraction).text
			+ 	Text(String.comaspace).foregroundStyle(.secondary)
			+ 	ValueView.cgFloat(value.y, fraction: fraction).text
		case let .cgSize(value, fraction):
				ValueView.cgFloat(value.width, fraction: fraction).text
			+ 	multiplyText
			+ 	ValueView.cgFloat(value.height, fraction: fraction).text
		case let .cgRect(value, fraction):
				Text(String.leftParenthesis).foregroundStyle(.secondary)
			+ 	ValueView.cgPoint(value.origin, fraction: fraction).text
			+ 	Text(String("), (")).foregroundStyle(.secondary)
			+ 	ValueView.cgSize(value.size, fraction: fraction).text
			+ 	Text(String.rightParenthesis).foregroundStyle(.secondary)
		case let .cgVector(value, fraction):
				ValueView.cgFloat(value.dx, fraction: fraction).text
			+ 	Text(String.comaspace).foregroundStyle(.secondary)
			+ 	ValueView.cgFloat(value.dy, fraction: fraction).text
		case let .edgeInsets(value, fraction):
				Text(String("top:")).foregroundStyle(.secondary)
			+ 	ValueView.cgFloat(value.top, fraction: fraction).text
			+ 	Text(String("bot:")).foregroundStyle(.secondary)
			+ 	ValueView.cgFloat(value.bottom, fraction: fraction).text
			+ 	Text(String("lead:")).foregroundStyle(.secondary)
			+ 	ValueView.cgFloat(value.leading, fraction: fraction).text
			+ 	Text(String("trail:")).foregroundStyle(.secondary)
			+ 	ValueView.cgFloat(value.trailing, fraction: fraction).text
		}
	}
	
	public var string: String {
		switch self {
		case let .undefined(value):
			value.description
		case let .string(string):
			string
		case let .text(text):
			"\(text)"
		case let .bool(bool, displayStyle):
			switch displayStyle {
			case .string:
				bool ? "true" : "false"
			case .int:
				bool ? "1" : "0"
			case .emoji,
				 .icon:
				bool.sign.s
			}
		case let .integer(integer):
			Int(integer).formatted(.number)
		case let .unsignedInteger(integer):
			UInt(integer).formatted(.number)
		case let .floatingPoint(value, fraction):
			Double(value).formatted(.number.precision(.fractionLength(fraction)))
		case let .cgFloat(value, fraction):
			Double(value).formatted(.number.precision(.fractionLength(fraction)))
		case let .cgPoint(value, fraction):
				ValueView.cgFloat(value.x, fraction: fraction).string
			+ 	String.comaspace
			+ 	ValueView.cgFloat(value.y, fraction: fraction).string
		case let .cgSize(value, fraction):
				ValueView.cgFloat(value.width, fraction: fraction).string
			+ 	multiplyString
			+ 	ValueView.cgFloat(value.height, fraction: fraction).string
		case let .cgRect(value, fraction):
				String.leftParenthesis
			+ 	ValueView.cgPoint(value.origin, fraction: fraction).string
			+ 	String("), (")
			+ 	ValueView.cgSize(value.size, fraction: fraction).string
			+ 	String.rightParenthesis
		case let .cgVector(value, fraction):
				ValueView.cgFloat(value.dx, fraction: fraction).string
			+ 	String.comaspace
			+ 	ValueView.cgFloat(value.dy, fraction: fraction).string
		case let .edgeInsets(value, fraction):
				String("top:")
			+ 	ValueView.cgFloat(value.top, fraction: fraction).string
			+ 	String("bot:")
			+ 	ValueView.cgFloat(value.bottom, fraction: fraction).string
			+ 	String("lead:")
			+ 	ValueView.cgFloat(value.leading, fraction: fraction).string
			+ 	String("trail:")
			+ 	ValueView.cgFloat(value.trailing, fraction: fraction).string
		}
	}
	
	// Helper for secondary label color across platforms
	#if os(iOS)
	private static let secondaryLabelColor = UIColor.secondaryLabel
	#elseif os(macOS)
	private static let secondaryLabelColor = NSColor.secondaryLabelColor
	#endif
	
	public var attributedString: AttributedString {
		switch self {
		case .undefined,
			 .string,
			 .text,
			 .bool,
			 .integer,
			 .unsignedInteger,
			 .floatingPoint,
			 .cgFloat:
			string.asAttributedString()
		case let .cgPoint(value, fraction):
				ValueView.cgFloat(value.x, fraction: fraction).attributedString
			+ 	String.comaspace.asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgFloat(value.y, fraction: fraction).attributedString
		case let .cgSize(value, fraction):
				ValueView.cgFloat(value.width, fraction: fraction).attributedString
			+ 	multiplyString.asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgFloat(value.height, fraction: fraction).attributedString
		case let .cgRect(value, fraction):
				String.leftParenthesis.asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgPoint(value.origin, fraction: fraction).attributedString
			+ 	String("), (").asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgSize(value.size, fraction: fraction).attributedString
			+ 	String.rightParenthesis.asAttributedString().foregroundColor(Self.secondaryLabelColor)
		case let .cgVector(value, fraction):
				ValueView.cgFloat(value.dx, fraction: fraction).attributedString
			+ 	String.comaspace.asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgFloat(value.dy, fraction: fraction).attributedString
		case let .edgeInsets(value, fraction):
				String("top:").asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgFloat(value.top, fraction: fraction).attributedString
			+ 	String("bot:").asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgFloat(value.bottom, fraction: fraction).attributedString
			+ 	String("lead:").asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgFloat(value.leading, fraction: fraction).attributedString
			+ 	String("trail:").asAttributedString().foregroundColor(Self.secondaryLabelColor)
			+ 	ValueView.cgFloat(value.trailing, fraction: fraction).attributedString
		}
	}
	
	fileprivate var multiplyString: String {
		NilReplacement.x.description
	}
	
	fileprivate var multiplyText: Text {
		Text(Image(systemName: "multiply"))
			.foregroundStyle(.secondary)
			.font(.system(size: 6, weight: .semibold))
			.baselineOffset(1)
	}
}

extension ValueView: @MainActor RawRepresentable {
	@inlinable public init?(rawValue: String) {
		self = .string(rawValue)
	}
	
	@inlinable public var rawValue: String {
		string
	}
}

extension ValueView: @MainActor LosslessStringConvertible {
	public init?(_ description: String) {
		self = .string(description)
	}
}

extension ValueView: @MainActor CustomStringConvertible {
	public var description: String {
		string
	}
}

extension ValueView: @MainActor ExpressibleByStringLiteral {
	public init(stringLiteral value: String) {
		self = .string(value)
	}
}

extension ValueView: @MainActor ExpressibleByBooleanLiteral {
	public init(booleanLiteral value: Bool) {
		self = .bool(value)
	}
}

extension ValueView: @MainActor ExpressibleByIntegerLiteral {
	public init(integerLiteral value: Int) {
		self = .integer(value)
	}
}

extension ValueView: @MainActor ExpressibleByFloatLiteral {
	public init(floatLiteral value: Double) {
		self = .floatingPoint(value)
	}
}

extension ValueView {
	public struct TransferableText: Transferable {
		public var string: String
		public var attributedString: AttributedString
		
		public static var transferRepresentation: some TransferRepresentation {
			ProxyRepresentation(exporting: \.string)
			ProxyRepresentation(exporting: \.attributedString)
		}
	}
	
	public var transferableText: TransferableText {
		.init(string: string, attributedString: attributedString)
	}
}
