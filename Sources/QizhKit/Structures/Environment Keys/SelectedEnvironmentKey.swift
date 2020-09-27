//
//  SelectedEnvironmentKey.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct SelectedKey: EnvironmentKey {
	public static let defaultValue: Bool = false
}

public extension EnvironmentValues {
	var selected: Bool {
		get { self[SelectedKey.self] }
		set { self[SelectedKey.self] = newValue }
	}
}

public extension View {
	@inlinable func selected(_ selected: Bool = true) -> some View {
		environment(\.selected, selected)
	}
}
