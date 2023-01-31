//
//  EnvironmentNextAction.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.01.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct EnvironmentNextActionKey: EnvironmentKey {
	public static var defaultValue: CustomEnvironmentAction = .doNothing
}

extension EnvironmentValues {
	public internal(set) var next: CustomEnvironmentAction {
		get { self[EnvironmentNextActionKey.self] }
		set { self[EnvironmentNextActionKey.self] = newValue }
	}
}

extension View {
	public func onNext(_ action: @escaping () -> Void) -> some View {
		environment(\.next, .init(action))
	}
	
	public func onNext(_ action: CustomEnvironmentAction) -> some View {
		environment(\.next, action)
	}
}
