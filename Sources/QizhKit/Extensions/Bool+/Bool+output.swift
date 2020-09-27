//
//  Bool+output.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 08.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Bool {
	var sign: Character {
		self ? .boltChar : .xMarkChar
	}
}
