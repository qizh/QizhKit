//
//  SwiftUIView.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 10.12.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(iOS, obsoleted: 15, message: "Implemented in SwiftUI")
extension View {
	@inlinable
	@_disfavoredOverload
	public func task(
		priority: TaskPriority = .userInitiated,
		_ action: @escaping @Sendable () async -> Void
	) -> some View {
		self.onAppear {
			Task(priority: priority, operation: action)
		}
	}
	
	@available(iOS 14.0, *)
	@inlinable
	@_disfavoredOverload
	public func task<T>(
		id value: T,
		priority: TaskPriority = .userInitiated,
		_ action: @escaping @Sendable () async -> Void
	) -> some View where T : Equatable {
		self.onChange(of: value) {
			Task(priority: priority, operation: action)
		}
	}
}
