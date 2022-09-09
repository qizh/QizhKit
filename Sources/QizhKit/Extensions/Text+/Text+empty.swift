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
	public static let nonBreakingSpaceText = Text(String.nonBreakingSpace)
	public static let newLineText = Text(String.newLine)
}
