//
//  Observable+binding.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 07.10.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Observation

@available(iOS 17.0, macOS 14.0, *)
extension Observable where Self: AnyObject {
	/// Returns a `Binding` to a mutable property on the observable object.
	/// - Parameters:
	///   - keyPath: a writable key path to a property.
	///   - onUpdate: optional callback whenever the value is set (after mutation).
	/// - Returns: a SwiftUI `Binding<Value>`
	@MainActor
	public func binding<Value>(
		for keyPath: ReferenceWritableKeyPath<Self, Value>,
		_ onUpdate: ((Value) -> Void)? = nil
	) -> Binding<Value> {
		Binding(
			get: { [weak self] in
				guard let self = self else {
					fatalError("Observable binding: object was deallocated")
				}
				return self[keyPath: keyPath]
			},
			set: { [weak self] newValue in
				guard let self = self else { return }
				self[keyPath: keyPath] = newValue
				onUpdate?(newValue)
			}
		)
	}
}
