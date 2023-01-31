//
//  EnvironmentSkipAction.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.01.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct EnvironmentSkipActionKey: EnvironmentKey {
	public static var defaultValue: CustomEnvironmentAction = .doNothing
}

extension EnvironmentValues {
	public internal(set) var skip: CustomEnvironmentAction {
		get { self[EnvironmentSkipActionKey.self] }
		set { self[EnvironmentSkipActionKey.self] = newValue }
	}
}

extension View {
	public func onSkip(_ action: @escaping () -> Void) -> some View {
		environment(\.skip, .init(action))
	}
	
	public func onSkip(_ action: CustomEnvironmentAction) -> some View {
		environment(\.skip, action)
	}
}
