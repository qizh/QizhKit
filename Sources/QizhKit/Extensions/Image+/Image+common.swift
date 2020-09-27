//
//  Image+common.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Image {
	@inlinable static func chevron(upWhen condition: Bool) -> Image {
		Image(systemName: condition
						? "chevron.up"
						: "chevron.down")
	}
	
	@inlinable static func bool(_ value: Bool) -> Image {
		Image(systemName: value
						? "checkmark"
						: "xmark")
	}
}
