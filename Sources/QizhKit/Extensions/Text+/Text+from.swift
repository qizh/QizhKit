//
//  Text+from.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension String {
	///  Converts the current value into a SwiftUI `Text`.
	///
	///  - Returns: A `Text` view initialized from the current value.
	///  - Discussion:
	///    Use this helper to create a SwiftUI `Text` view from a `String`.
	///    Similar helpers exist for `LocalizedStringResource` and
	///    `Optional<LocalizedStringResource>`.
	///  - SeeAlso: `Text` for composing and styling textual content in SwiftUI.
	@inlinable public func asText() -> Text {
		Text(self)
	}
}

extension LocalizedStringResource {
	///  Converts the current value into a SwiftUI `Text` view.
	///
	///  - Returns: A `Text` initialized from the current value.
	///  - Discussion:
	///    Converts this localized string resource into a SwiftUI `Text` view.
	///  - SeeAlso: `Text` for composing and styling textual content in SwiftUI.
	@inlinable public func asText() -> Text {
		Text(self)
	}
}

extension Optional<LocalizedStringResource> {
	///  Converts an optional localized string resource into `Text`, with a fallback.
	///
	///  - Parameter fallback: The `Text` to return when this optional is `nil`.
	///    Defaults to an empty `Text("")`.
	///  - Returns: A `Text` initialized from the wrapped value if present,
	///    or the fallback otherwise.
	///  - Discussion:
	///    Use this helper when you need a guaranteed `Text` instance,
	///    not an optional. The fallback ensures you always get a valid view.
	@inlinable public func asText(fallback: Text = Text("")) -> Text {
		switch self {
		case .none: fallback
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
