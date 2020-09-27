//
//  HighlightEnvironmentKey.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct HighlightColorKey: EnvironmentKey {
	public static let defaultValue: Color? = nil
}

public extension EnvironmentValues {
	var highlightColor: Color? {
		get { self[HighlightColorKey.self] }
		set { self[HighlightColorKey.self] = newValue }
	}
}
