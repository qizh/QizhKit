//
//  CustomStringConvertable+sugar.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.12.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Collection where Element: CustomStringConvertible {
	@inlinable public var descriptions: [String] {
		map(\.description)
	}
}
