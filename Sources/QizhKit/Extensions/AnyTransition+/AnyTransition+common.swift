//
//  AnyTransition+common.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.01.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension AnyTransition {
	@MainActor public static let unslide: Self =
		.asymmetric(
			insertion: .move(edge: .trailing),
			  removal: .move(edge: .leading)
		)
	
	@MainActor public static let jump: Self =
		.asymmetric(
			insertion: .move(edge: .bottom),
			  removal: .move(edge: .top)
		)
	
	@MainActor public static let fall: Self =
		.asymmetric(
			insertion: .move(edge: .top),
			  removal: .move(edge: .bottom)
		)
	
	@MainActor public static func asymmetricHorizontalOffset(distance: CGFloat) -> Self {
		.asymmetric(
			insertion: .offset(x: -distance) + .opacity,
			removal: .offset(x: distance) + .opacity
		)
	}
}
