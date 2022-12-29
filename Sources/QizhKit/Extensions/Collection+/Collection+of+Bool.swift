//
//  Collection+of+Bool.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 29.12.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Collection<Bool> {
	@inlinable
	public func and() -> Bool {
		reduce(true) { partialResult, element in
			partialResult && element
		}
	}
	
	@inlinable
	public func or() -> Bool {
		reduce(false) { partialResult, element in
			partialResult || element
		}
	}
}
