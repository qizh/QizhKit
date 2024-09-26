//
//  AnyInsettableShape.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.01.2022.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct AnyInsettableShape: InsettableShape, Sendable {
	private let makePath: @Sendable (CGRect) -> Path
	private let makeInset: @Sendable (CGFloat) -> AnyInsettableShape

	public init<S: InsettableShape & Sendable>(_ shape: S) {
		// Capture a copy of the shape to ensure it's Sendable
		let shapeCopy = shape
		makePath = { rect in shapeCopy.path(in: rect) }
		makeInset = { amount in AnyInsettableShape(shapeCopy.inset(by: amount)) }
	}

	public func path(in rect: CGRect) -> Path {
		makePath(rect)
	}

	public func inset(by amount: CGFloat) -> AnyInsettableShape {
		makeInset(amount)
	}
}

extension InsettableShape {
	public func asAnyInsettableShape() -> AnyInsettableShape {
		AnyInsettableShape(self)
	}
}
