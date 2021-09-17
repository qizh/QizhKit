//
//  TopHorizontalLine.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 17.09.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct TopHorizontalLine: Shape {
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		path.addLines([[rect.minX, rect.minY], [rect.maxX, rect.minY]])
		return path
	}
}

public struct DiagonalLine: Shape {
	private let direction: Direction
	
	public init(direction: DiagonalLine.Direction) {
		self.direction = direction
	}
	
	public func path(in rect: CGRect) -> Path {
		var path = Path()
		switch direction {
		case .slash:
			path.move(to: CGPoint(x: rect.maxX, y: rect.minY))
			path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
		case .backslash:
			path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
			path.addLine(to: CGPoint(x: rect.maxX, y: rect.minY))
		}
		return path
	}
	
	public enum Direction {
		case slash
		case backslash
	}
}
