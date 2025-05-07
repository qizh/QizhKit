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

// MARK: Common use case

extension View {
	@inlinable
	public func alignmentGuide(_ g: HorizontalAlignment, value: CGFloat) -> some View {
		alignmentGuide(g, computeValue: { _ in value })
	}
	
	@inlinable
	public func alignmentGuide(_ g: VerticalAlignment, value: CGFloat) -> some View {
		alignmentGuide(g, computeValue: { _ in value })
	}
}

// MARK: + Case Name

extension VerticalAlignment {
	@inlinable public var caseName: String {
		switch self {
		case .top: 					"top"
		case .bottom: 				"bottom"
		case .center: 				"center"
		case .firstTextBaseline: 	"firstTextBaseline"
		case .lastTextBaseline: 	"lastTextBaseline"
			
		case .topSide: 				"topSide"
		case .topEdge: 				"topEdge"
		case .bottomSide: 			"bottomSide"
		case .bottomEdge: 			"bottomEdge"
			
		default: 					"unknown"
		}
	}
	
	@inlinable public var caseNameSimplified: String {
		switch self {
		case .top: 					"top"
		case .bottom: 				"bottom"
		case .center: 				.empty
		case .firstTextBaseline: 	"firstTextBaseline"
		case .lastTextBaseline: 	"lastTextBaseline"
			
		case .topSide: 				"topSide"
		case .topEdge: 				"topEdge"
		case .bottomSide: 			"bottomSide"
		case .bottomEdge: 			"bottomEdge"
			
		default: 					.empty
		}
	}
}

extension HorizontalAlignment {
	@inlinable public var caseName: String {
		switch self {
		case .leading: 				"leading"
		case .trailing: 			"trailing"
		case .center: 				"center"
		
		case .leadingSide: 			"leadingSide"
		case .trailingSide: 		"trailingSide"
		case .separator: 			"separator"
			
		default: 					"unknown"
		}
	}
	
	@inlinable public var caseNameSimplified: String {
		switch self {
		case .leading: 				"leading"
		case .trailing: 			"trailing"
		case .center: 				.empty
		
		case .leadingSide: 			"leadingSide"
		case .trailingSide: 		"trailingSide"
		case .separator: 			"separator"
			
		default: 					.empty
		}
	}
}

extension Alignment {
	public var caseName: String {
		"\(horizontal.caseNameSimplified)\(vertical.caseNameSimplified)".toCamelCase
	}
}

// MARK: + Description

extension VerticalAlignment: @retroactive CustomStringConvertible {
	@inlinable public var description: String { "vertical.\(caseName)" }
}

extension HorizontalAlignment: @retroactive CustomStringConvertible {
	@inlinable public var description: String { "horizontal.\(caseName)" }
}

extension Alignment: @retroactive CustomStringConvertible {
	@inlinable public var description: String { "alignment.\(caseName)" }
}
