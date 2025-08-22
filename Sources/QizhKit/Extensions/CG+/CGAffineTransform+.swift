//
//  CGAffineTransform+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 17.07.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Scaled with anchor

extension CGAffineTransform {
	@MainActor public func scaled(
		by scale: CGFloat,
		with anchor: CGPoint
	) -> CGAffineTransform {
		self
			.translatedBy(x: anchor.x, y: anchor.y)
			.scaledBy(x: scale, y: scale)
			.translatedBy(x: -anchor.x, y: -anchor.y)
	}
}

// MARK: +Hashable

extension CGAffineTransform: @retroactive Hashable,
							 @retroactive @unchecked Sendable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(a)
		hasher.combine(b)
		hasher.combine(c)
		hasher.combine(d)
		hasher.combine(tx)
		hasher.combine(ty)
	}
}

