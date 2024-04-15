//
//  AnyShape.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.01.2022.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(iOS, introduced: 14.0, obsoleted: 16.0, message: "There's SwiftUI native AnyShape")
public struct AnyShape: Shape {
	private let makePath: (CGRect) -> Path
	
	public init<S: Shape>(_ shape: S) {
		makePath = shape.path(in:)
	}
	
	public func path(in rect: CGRect) -> Path {
		makePath(rect)
	}
}

public struct AnyInsettableShape: InsettableShape {
	private let makePath: (CGRect) -> Path
	private let makeInset: (CGFloat) -> AnyInsettableShape
	
	public init<S: InsettableShape>(_ shape: S) {
		makePath = shape.path(in:)
		makeInset = { AnyInsettableShape(shape.inset(by: $0)) }
	}
	
	public func path(in rect: CGRect) -> Path {
		makePath(rect)
	}
	
	public func inset(by amount: CGFloat) -> AnyInsettableShape {
		makeInset(amount)
	}
}

@available(iOS, introduced: 14.0, obsoleted: 16.0, message: "There's SwiftUI native AnyShape")
extension Shape {
	@inlinable public func asAnyShape() -> AnyShape {
		AnyShape(self)
	}
}

extension InsettableShape {
	public func asAnyInsettableShape() -> AnyInsettableShape {
		AnyInsettableShape(self)
	}
}
