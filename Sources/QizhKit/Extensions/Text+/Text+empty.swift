//
//  Text+empty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension Text {
	public static let emptyText = Text(String.empty)
	
	public static let spaceText = Text(String.space)
	public static func spaceText(_ count: UInt) -> Text {
		Text(String.space * count)
	}
	
	public static let nonBreakingSpaceText = Text(String.nonBreakingSpace)
	public static func nonBreakingSpaceText(_ count: UInt) -> Text {
		Text(String.nonBreakingSpace * count)
	}
	
	public static let newLineText = Text(String.newLine)
	public static func newLineText(_ count: UInt) -> Text {
		Text(String.newLine * count)
	}
}

extension Text {
	public static func * (_ text: Text, _ count: UInt) -> Text {
		Array<Text>(repeating: text, count: Int(count))
			.joined(separator: .emptyText)
	}
}
