//
//  HighlightEnvironmentKey.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
	@Entry public var highlightColor: Color? = nil
}

extension View {
	public func highlightColor(_ color: Color?) -> some View {
		environment(\.highlightColor, color)
	}
}
