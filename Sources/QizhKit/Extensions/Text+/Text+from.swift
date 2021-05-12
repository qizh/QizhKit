//
//  Text+from.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension String {
	@inlinable func asText() -> Text {
		Text(self)
	}
}

public extension Text {
	static func + (lhs: Text, rhs: Text?) -> Text {
		switch rhs {
		case .some(let text): return lhs + text
		case .none: return lhs
		}
	}
}
