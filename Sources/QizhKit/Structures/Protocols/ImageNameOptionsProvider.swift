//
//  ImageNameOptionsProvider.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public protocol ImageNameOptionsProvider: ExpressibleByStringLiteral {
	var name: String { get }
	@MainActor init(stringLiteral value: String)
}

public extension ImageNameOptionsProvider {
	@MainActor static func named(_ name: String) -> Self { .init(stringLiteral: name) }
	var image: Image { Image(name) }
}
