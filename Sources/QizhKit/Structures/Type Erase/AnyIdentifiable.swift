//
//  AnyIdentifiable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public struct AnyIdentifiable: Identifiable {
	public let id: AnyHashable
	
	public init<T: Identifiable>(_ identifiable: T) {
		self.id = identifiable.id
	}
}

public extension Identifiable {
	@inlinable func asAnyIdentifiable() -> AnyIdentifiable {
		AnyIdentifiable(self)
	}
}
