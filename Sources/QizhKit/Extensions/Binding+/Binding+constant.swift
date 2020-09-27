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
