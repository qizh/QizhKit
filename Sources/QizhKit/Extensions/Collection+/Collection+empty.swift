//
//  Collection+empty.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 14.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection {
	@inlinable var hasMoreThanOne: Bool { count > .one }
	@inlinable var     isNotAlone: Bool { count > .one }
	@inlinable var        isAlone: Bool { count .isOne }
	@inlinable var          alone: Self? {     isAlone ? self : .none }
	@inlinable var       nonAlone: Self? {  isNotAlone ? self : .none }
	@inlinable var    moreThanOne: Self? {  isNotAlone ? self : .none }
	
	@inlinable var justOne: Element? { isAlone ? first : .none }
	@inlinable var    only: Element? { isAlone ? first : .none }
}
