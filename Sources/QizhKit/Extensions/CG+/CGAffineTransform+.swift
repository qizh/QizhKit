//
//  CGAffineTransform+.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 17.07.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension CGAffineTransform {
	public func scaled(
		by scale: CGFloat,
		with anchor: CGPoint
	) -> CGAffineTransform {
		self
			.translatedBy(x: anchor.x, y: anchor.y)
			.scaledBy(x: scale, y: scale)
			.translatedBy(x: -anchor.x, y: -anchor.y)
	}
}
