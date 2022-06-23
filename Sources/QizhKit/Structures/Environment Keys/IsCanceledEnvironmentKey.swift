//
//  IsCanceledEnvironmentKey.swift
//  QizhKit
//
//  Created by Сергій Шевченко on 23.06.2022.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct IsCanceledKey: EnvironmentKey {
	public static let defaultValue: Bool = false
}

extension EnvironmentValues {
	public var isCanceled: Bool {
		get { self[IsCanceledKey.self] }
		set { self[IsCanceledKey.self] = newValue }
	}
}

extension View {
	public func isCanceled(_ isCanceled: Bool = true) -> some View {
		environment(\.isCanceled, isCanceled)
	}
}
