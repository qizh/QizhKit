//
//  EnvironmentKey+isInPreview.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 19.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct IsInPreviewKey: EnvironmentKey {
	public static let defaultValue: Bool = false
}

public extension EnvironmentValues {
	var isInPreview: Bool {
		get { self[IsInPreviewKey.self] }
		set { self[IsInPreviewKey.self] = newValue }
	}
}

public extension View {
	func isInPreview() -> some View {
		environment(\.isInPreview, true)
	}
}
