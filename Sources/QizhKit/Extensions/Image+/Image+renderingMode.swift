//
//  Image+renderingMode.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Image {
	@inlinable func template() -> Image { renderingMode(.template) }
	@inlinable func original() -> Image { renderingMode(.original) }
}
