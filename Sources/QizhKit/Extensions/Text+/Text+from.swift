//
//  Text+from.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension String {
	@inlinable
	public func asText() -> Text {
		Text(self)
	}
}

extension LocalizedStringResource {
	@inlinable public func asText() -> Text {
		Text(self)
	}
}

extension Optional<LocalizedStringResource> {
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
