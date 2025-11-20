//
//  Text+from.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension String {
	/// Converts the current value into a SwiftUI `Text`.
	///
	/// - Returns: A `Text` view initialized from the current value.
	/// - Discussion:
	///   Use this helper to turn different textual values into SwiftUI `Text`:
	///   - For `String`, it returns `Text(self)`.
	///   - For `LocalizedStringResource`, it returns `Text(self)`.
	///   - For `Optional<LocalizedStringResource>`, it returns an optional `Text`
	///     (`nil` when the optional is `.none`).
	/// - SeeAlso: `Text` for composing and styling textual content in SwiftUI.
	@inlinable public func asText() -> Text {
		Text(self)
	}
}

extension LocalizedStringResource {
	/// Converts the current value into a SwiftUI `Text` view.
	///
	/// - Returns: A `Text` initialized from the current value.
	/// - Discussion:
	///   Use this helper to turn different textual values into SwiftUI `Text`:
	///   - For `String`, it returns `Text(self)`.
	///   - For `LocalizedStringResource`, it returns `Text(self)`.
	///   - For `Optional<LocalizedStringResource>`, it returns an optional `Text`
	///     (`nil` when the optional is `.none`).
	/// - SeeAlso: `Text` for composing and styling textual content in SwiftUI.
	@inlinable public func asText() -> Text {
		Text(self)
	}
}

extension Optional<LocalizedStringResource> {
	/// Converts the current value into an optional SwiftUI `Text` view.
	///
	/// - Returns: An optional `Text` initialized from the current value, or `nil` if the optional is `.none`.
	/// - Discussion:
	///   Use this helper to turn different textual values into SwiftUI `Text`:
	///   - For `String`, it returns `Text(self)`.
	///   - For `LocalizedStringResource`, it returns `Text(self)`.
	///   - For `Optional<LocalizedStringResource>`, it returns an optional `Text`
	///     (`nil` when the optional is `.none`).
	/// - SeeAlso: `Text` for composing and styling textual content in SwiftUI.
	public func asText() -> Text? {
		switch self {
		case .none: .none
		case .some(let wrapped): Text(wrapped)
		}
	}
}

extension Text {
	public static func + (lhs: Text, rhs: Text?) -> Text {
		switch rhs {
		case .some(let text): return lhs + text
		case .none: return lhs
		}
	}
	
	public static func + (lhs: Text, rhs: String) -> Text {
		lhs + Text(rhs)
	}
	
	public static func + (lhs: String, rhs: Text) -> Text {
		Text(lhs) + rhs
	}
}

extension Collection where Element == Text {
	@inlinable
	public func joined(separator: Text) -> Text {
		reduce(.empty) { partialResult, nextText in
			partialResult.isEmpty
				? nextText
				: partialResult + separator + nextText
		}
	}
}
