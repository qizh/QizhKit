//
//  EnvironmentKey+isInPreview.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 19.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension EnvironmentValues {
	@Entry public var isInPreview: Bool = false
}

extension View {
	public func isInPreview() -> some View {
		environment(\.isInPreview, true)
	}
}
