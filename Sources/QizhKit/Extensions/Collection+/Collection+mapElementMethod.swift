//
//  Collection+mapElementMethod.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.12.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Prepare, then map

public extension Collection where Element: Sendable {
	@inlinable
	func map <Input: Sendable, Output: Sendable> (
		calling transform: @Sendable (Element) -> (Input) -> Output,
		with argument: Input
	) -> [Output] {
		map { element in
			transform(element)(argument)
		}
	}
	
	@inlinable
	func map <Input1: Sendable, Input2: Sendable, Output: Sendable> (
		calling transform: @Sendable (Element) -> (Input1, Input2) -> Output,
		with    argument1: Input1,
		and     argument2: Input2
	) -> [Output] {
		map { element in
			transform(element)(argument1, argument2)
		}
	}
}

// MARK: Map with arguments

public extension Collection where Element: Sendable {
	@inlinable
	func map <Argument: Sendable, Output: Sendable> (
		_ transform: @Sendable (Element, Argument) -> Output,
		_ argument: Argument
	) -> [Output] {
		map { element in
			transform(element, argument)
		}
	}
	
	@inlinable
	func map <Argument: Sendable, Output: Sendable> (
		_ argument: Argument,
		_ transform: @Sendable (Argument, Element) -> Output
	) -> [Output] {
		map { element in
			transform(argument, element)
		}
	}
	
	@inlinable
	func compactMap <Argument: Sendable, Output: Sendable> (
		_ transform: @Sendable (Element, Argument) -> Output?,
		_ argument: Argument
	) -> [Output] {
		compactMap { element in
			transform(element, argument)
		}
	}
	
	@inlinable
	func compactMap <Argument: Sendable, Output: Sendable> (
		_ argument: Argument,
		_ transform: @Sendable (Argument, Element) -> Output?
	) -> [Output] {
		compactMap { element in
			transform(argument, element)
		}
	}
}
