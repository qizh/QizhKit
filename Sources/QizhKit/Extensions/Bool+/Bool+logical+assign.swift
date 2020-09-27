//
//  Bool+logical+assign.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 21.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

infix operator ||= : AssignmentPrecedence
infix operator &&= : AssignmentPrecedence

public extension Bool {
	static func ||= (left: inout Bool, right: @autoclosure () -> Bool) {
		if !left {
			left = right()
		}
	}
	
	static func &&= (left: inout Bool, right: @autoclosure () -> Bool) {
		if left {
		   left = right()
		}
	}
}
