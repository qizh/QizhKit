//
//  AttributedString+String.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 29.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

#if os(iOS) || targetEnvironment(macCatalyst)
import UIKit
public typealias PlatformColor = UIColor
#elseif os(macOS)
import AppKit
public typealias PlatformColor = NSColor
#endif
import SwiftUI

extension AttributedString {
	/// All characters combined into string
	public var underlyingString: String {
		String(self.characters[...])
	}
}

extension AttributedString {
	@inlinable public func foregroundColor(_ color: Color) -> AttributedString {
		transformingAttributes(\.foregroundColor) { foregroundColor in
			foregroundColor.value = color
		}
	}
	
	@inlinable public func foregroundColor(_ color: PlatformColor) -> AttributedString {
		transformingAttributes(\.foregroundColor) { foregroundColor in
			foregroundColor.value = Color(color)
		}
	}
}

extension AttributedString: EmptyTestable {}
extension AttributedString: EmptyProvidable {}
extension AttributedString: AnyEmptyProvidable {}
extension AttributedString: EmptyComparable {
	/// Initialized with empty `String` literal
	public static var empty: AttributedString {
		.init(stringLiteral: .empty)
	}
}

extension String {
	@inlinable public func asAttributedString() -> AttributedString {
		AttributedString(self)
	}
}
