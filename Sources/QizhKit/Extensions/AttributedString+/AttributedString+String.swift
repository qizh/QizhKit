//
//  AttributedString+String.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 29.08.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension AttributedString {
	/// All characters combined into string
	public var underlyingString: String {
		String(self.characters[...])
	}
}

extension AttributedString {
	/// Cross-platform helper using SwiftUI.Color
	@inlinable public func foregroundColor(_ color: Color) -> AttributedString {
		transformingAttributes(\.foregroundColor) { foregroundColor in
			foregroundColor.value = color
		}
	}

	#if canImport(UIKit)
	/// iOS convenience overload
	@inlinable public func foregroundColor(_ color: UIColor) -> AttributedString {
		foregroundColor(Color(uiColor: color))
	}
	#endif
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
