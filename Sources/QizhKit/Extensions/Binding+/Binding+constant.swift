//
//  Binding+constant.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Binding where Value == Bool {
	static var  `true`: Self { .constant(true) }
	static var `false`: Self { .constant(false) }
}

public extension Binding where Value: EmptyProvidable {
	static var empty: Self { .constant(.empty) }
}

public extension Binding where Value: WithDefault {
	static var `default`: Self { .constant(.default) }
}

public extension Binding where Value: WithUnknown {
	static var unknown: Self { .constant(.unknown) }
}

public extension Binding where Value: AdditiveArithmetic {
	static var zero: Self { .constant(.zero) }
}

public extension Binding where Value: TypedOptionalConvertible {
	static var none: Self { .constant(.none) }
}

public extension Binding where Value == Date {
	static var now: Self { .constant(.now) }
	static var reference0: Self { .constant(.reference0) }
}

// MARK: is constant?

extension Binding {
	/// A Boolean value indicating whether this `Binding` instance
	/// represents a constant binding.
	///
	/// This property uses Swift’s `Mirror` to inspect the underlying storage
	/// and checks for a type name containing "Constant", which is how SwiftUI
	/// represents a binding created from a literal or constant value.
	///
	/// - Warning: Do not rely on this property in production.
	/// 	Because this implementation relies on undocumented details
	/// 	and may break in any SwiftUI update.
	public var isConstantMirror: Bool {
		Mirror(reflecting: self)
			.children
			.contains { _, value in
				String(describing: type(of: value))
					.contains("Constant")
			}
	}
}
