//
//  Collection+mapElementMethod.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection {
	@inlinable
	func map <Input, Output> (
		calling transform: (Element) -> (Input) -> Output,
		with argument: Input
	) -> [Output] {
		map { element in
			transform(element)(argument)
		}
	}
	
	@inlinable
	func map <Input1, Input2, Output> (
		calling transform: (Element) -> (Input1, Input2) -> Output,
		with    argument1: Input1,
		and     argument2: Input2
	) -> [Output] {
		map { element in
			transform(element)(argument1, argument2)
		}
	}
}
