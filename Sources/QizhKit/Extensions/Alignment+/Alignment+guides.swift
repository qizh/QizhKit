//
//  Alignment+guides.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 12.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension HorizontalAlignment {
	private enum Separator: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat { context[HorizontalAlignment.center] }
	}
	
	private enum LeadingSide: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat { context[.leading] }
	}

	private enum TrailingSide: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat { context[.trailing] }
	}
	
	static let separator = HorizontalAlignment(Separator.self)
	static let leadingSide = HorizontalAlignment(LeadingSide.self)
	static let trailingSide = HorizontalAlignment(TrailingSide.self)
}

public extension VerticalAlignment {
	private enum BottomSide: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat { context[.bottom] }
	}
	
	private enum TopSide: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat { context[.top] }
	}
	
	private enum BottomEdge: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat { context[.bottom] }
	}
	
	private enum TopEdge: AlignmentID {
		static func defaultValue(in context: ViewDimensions) -> CGFloat { context[.top] }
	}
	
	static let topSide = VerticalAlignment(TopSide.self)
	static let topEdge = VerticalAlignment(TopEdge.self)
	static let bottomSide = VerticalAlignment(BottomSide.self)
	static let bottomEdge = VerticalAlignment(BottomEdge.self)
}

public extension Alignment {
	static let topSide = Alignment(horizontal: .center, vertical: .topSide)
	static let topEdge = Alignment(horizontal: .center, vertical: .topEdge)
	static let bottomSide = Alignment(horizontal: .center, vertical: .bottomSide)
	static let bottomEdge = Alignment(horizontal: .center, vertical: .bottomEdge)

	static let separator = Alignment(horizontal: .separator, vertical: .center)
	static let leadingSide = Alignment(horizontal: .leadingSide, vertical: .center)
	static let trailingSide = Alignment(horizontal: .trailingSide, vertical: .center)
}
