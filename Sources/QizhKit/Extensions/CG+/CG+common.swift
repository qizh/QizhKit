//
//  CG+common.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 14.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: - CGFloat

public extension CGFloat {
	func scaled(_ factor: Double) -> CGFloat {
		var copy = self
		copy.scale(by: factor)
		return copy
	}
	
	@inlinable func scaled(_ factor: Factor) -> CGFloat { scaled(factor.value) }
	
	func fraction(of value: CGFloat) -> Factor {
		switch self {
		case .zero: return .zero
		case value: return .one
		default: 	return .init(value / self)
		}
	}
	
	@inlinable static func * (l: Int, r: CGFloat) -> CGFloat {
		l.cg * r
	}
}

// MARK: - CGPoint

public extension CGPoint {
	@inlinable init(_ x: CGFloat, _ y: CGFloat) { self.init(x: x, y: y) }
	@inlinable static func point(_ x: CGFloat, _ y: CGFloat) -> CGPoint { .init(x, y) }
	@inlinable static func x(_ x: CGFloat) -> CGPoint { .init(x, 0) }
	@inlinable static func y(_ y: CGFloat) -> CGPoint { .init(0, y) }
}

extension CGPoint: ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: CGFloat...) {
		self.init(elements.first ?? .zero, elements.second ?? .zero)
	}
}

public extension CGPoint {
	@inlinable func scaled(_ factor: Factor) -> CGPoint { scaled(.both(factor)) }
	@inlinable func scaled(_ factor: AxisFactor) -> CGPoint { scaled(factor.horizontal, factor.vertical) }
	@inlinable func scaled(_ horizontal: Factor, _ vertical: Factor) -> CGPoint {
		CGPoint(x.scaled(horizontal), y.scaled(vertical))
	}
}

public extension CGPoint {
	var opposite: CGPoint {
		CGPoint(x: -x, y: -y)
	}
}

public extension CGPoint {
	@inlinable func offset(_ dx: CGFloat, _ dy: CGFloat) -> CGPoint { CGPoint(x + dx, y + dy) }
	
	@inlinable func offset(x dx: CGFloat) -> CGPoint { CGPoint(x + dx, y) }
	@inlinable func offset(y dy: CGFloat) -> CGPoint { CGPoint(x, y + dy) }
	@inlinable func offset(_  p: CGPoint) -> CGPoint { offset(p.x, p.y) }
	@inlinable func offset(_  s: CGSize)  -> CGPoint { offset(s.width, s.height) }
}

public extension CGPoint {
	@inlinable func moving(x: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
	@inlinable func moving(y: CGFloat) -> CGPoint { CGPoint(x: x, y: y) }
	
	@inlinable func moving(
		to destination: CGPoint,
		 with progress: Factor
	) -> CGPoint {
		moving(to: destination, with: progress.both)
	}
	
	@inlinable func moving(
		to destination: CGPoint,
		 with progress: AxisFactor
	) -> CGPoint {
		CGPoint(
			x + (destination.x - x).scaled(progress.horizontal),
			y + (destination.y - y).scaled(progress.vertical)
		)
	}
}

public extension CGPoint {
	func offset(
		    in size: CGSize,
		from anchor: UnitPoint
	) -> CGPoint {
		switch anchor {
		case .zero           : fallthrough
		case .topLeading     : return CGPoint(                        0, 0                         )
		case .top            : return CGPoint(         -size.width.half, 0                         )
		case .topTrailing    : return CGPoint(         -size.width     , 0                         )
		case .leading        : return CGPoint(                        0, -size.height.half         )
		case .center         : return CGPoint(         -size.width.half, -size.height.half         )
		case .trailing       : return CGPoint(         -size.width     , -size.height.half         )
		case .bottomLeading  : return CGPoint(                        0, -size.height              )
		case .bottom         : return CGPoint(         -size.width.half, -size.height              )
		case .bottomTrailing : return CGPoint(         -size.width     , -size.height              )
		default              : return CGPoint( -(anchor.x * size.width), -(anchor.y * size.height) )
		}
	}
	
	@inlinable func offset(
		    in size: CGPoint,
		from anchor: UnitPoint
	) -> CGPoint {
		offset(in: size.size, from: anchor)
	}
	
	@inlinable func offset(
		    in size: CGSize,
		from anchor: UnitPoint,
			 factor: AxisFactor
	) -> CGPoint {
		offset(offset(in: size, from: anchor).scaled(factor))
	}
	
	@inlinable func offset(
		  in offset: CGPoint,
		from anchor: UnitPoint,
		     factor: AxisFactor
	) -> CGPoint {
		self.offset(in: offset.size, from: anchor, factor: factor)
	}
}

public extension CGPoint {
	@inlinable  var size: CGSize { CGSize(x, y) }
	@inlinable func distance(to point: CGPoint) -> CGFloat {
		√((point.x - x).² + (point.y - y).²)
	}
	@inlinable func angle(to point: CGPoint) -> Angle {
		atan2(point.y - y, point.x - x).radians + 90.degrees
	}
	@inlinable func rect(to point: CGPoint) -> CGRect {
		CGRect(from: self, to: point)
	}
	
	func map(from: CGRect, to: CGRect) -> CGPoint {
		CGPoint(
			to.minX.scaled(from.width .fraction(of: x - from.minX)),
			to.minY.scaled(from.height.fraction(of: y - from.minY))
		)
	}
}

extension CGPoint: AdditiveArithmetic {
	public static func + (l: CGPoint, r: CGPoint) -> CGPoint { CGPoint(l.x + r.x, l.y + r.y) }
	public static func - (l: CGPoint, r: CGPoint) -> CGPoint { CGPoint(l.x - r.x, l.y - r.y) }
	public static prefix func -(value: CGPoint) -> CGPoint { CGPoint(-value.x, -value.y) }
}

public extension CGPoint {
	@inlinable var s0: String { "{\(x.s0), \(y.s0)}" }
	@inlinable var s1: String { "{\(x.s1), \(y.s1)}" }
	@inlinable var s2: String { "{\(x.s2), \(y.s2)}" }
}

// MARK: - Size

public extension CGSize {
	@inlinable init(_ width: CGFloat, _ height: CGFloat) { self.init(width: width, height: height) }
	@inlinable static func      width(_  width: CGFloat) -> CGSize { CGSize(width, .zero) }
	@inlinable static func     height(_ height: CGFloat) -> CGSize { CGSize(.zero, height) }
	@inlinable static func          x(_  width: CGFloat) -> CGSize { CGSize(width, .zero) }
	@inlinable static func          y(_ height: CGFloat) -> CGSize { CGSize(.zero, height) }
	@inlinable static func horizontal(_  width: CGFloat) -> CGSize { CGSize(width, .zero) }
	@inlinable static func   vertical(_ height: CGFloat) -> CGSize { CGSize(.zero, height) }
	@inlinable static func     square(_   size: CGFloat) -> CGSize { CGSize( size, size) }
	@inlinable static func       size(_   size: CGFloat) -> CGSize { CGSize( size, size) }
	@inlinable static func       size(_  width: CGFloat, _ height: CGFloat) -> CGSize { CGSize(width, height) }
	
	@inlinable static func both(_ factor: Factor) -> AxisFactor { AxisFactor(factor) }
}

extension CGSize: ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: CGFloat...) {
		self.init(elements.first ?? .zero, elements.second ?? .zero)
	}
}

public extension CGSize {
	@inlinable func scaled(_ factor: Factor) -> CGSize { scaled(.both(factor)) }
	@inlinable func scaled(_ factor: AxisFactor) -> CGSize { scaled(factor.horizontal, factor.vertical) }
	@inlinable func scaled(_ horizontal: Factor, _ vertical: Factor) -> CGSize {
		CGSize(width.scaled(horizontal), height.scaled(vertical))
	}
}

public extension CGSize {
	@inlinable var smallerSide: CGFloat { Swift.min(width, height) }
	@inlinable var  biggerSide: CGFloat { Swift.max(width, height) }
}

public extension CGSize {
	@inlinable static var infinity: CGSize {
		CGSize(
			width: CGFloat.infinity,
			height: CGFloat.infinity
		)
	}
	
	@inlinable var isFinite   : Bool { width.isFinite && height.isFinite }
	@inlinable var isZero     : Bool { width.isZero   && height.isZero }
	@inlinable var isInfinite : Bool { !isFinite }
	@inlinable var isNotZero  : Bool { !isZero }
	@inlinable var finite     : CGSize? { isFinite ? self : nil }
	@inlinable var nonZero    : Self?   { isZero   ? nil : self }
	@inlinable var area       : CGFloat { width * height }
	@inlinable var center     : CGPoint { CGPoint(width.half, height.half) }
}

public extension CGSize {
	@inlinable func expandBy(dx: CGFloat = .zero, dy: CGFloat = .zero) -> CGSize {
		CGSize(width: width + dx, height: height + dy)
	}
}

public extension CGSize {
	@inlinable var point: CGPoint { CGPoint(width, height) }
}

public extension CGSize {
	@inlinable var s0: String { "[\(width.s0) x \(height.s0)]" }
	@inlinable var s1: String { "[\(width.s1) x \(height.s1)]" }
	@inlinable var s2: String { "[\(width.s2) x \(height.s2)]" }
}

extension CGSize: Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(width)
		hasher.combine(height)
	}
}

/*
public func min(_ x: CGSize, _ y: CGSize) -> CGSize {
	CGSize(
		 width: min(x.width,  y.width),
		height: min(x.height, y.height)
	)
}
*/

extension CGSize: Comparable {
	@inlinable public static func < (l: CGSize, r: CGSize) -> Bool { l.area < r.area }
}

// MARK: - Rect

public extension CGRect {
	@inlinable init(_ x: CGFloat, _ y: CGFloat, _ width: CGFloat, _ height: CGFloat) {
		self.init(origin: CGPoint(x, y), size: CGSize(width, height))
	}
	@inlinable init(_ width: CGFloat, _ height: CGFloat) { self.init(0, 0, width, height) }
	@inlinable init(_ origin: CGPoint, _ size: CGSize) { self.init(origin: origin, size: size) }
	
	@inlinable static func rect(
		_ x: CGFloat, _ y: CGFloat,
		_ w: CGFloat, _ h: CGFloat
	) -> CGRect { .init(x, y, w, h) }
	
	@inlinable static func rect( _ width: CGFloat, _ height: CGFloat) -> CGRect { CGRect(width, height) }
	@inlinable static func rect(_ origin: CGPoint,   _ size: CGSize)  -> CGRect { CGRect(origin, size) }
	
	@inlinable init(standartizing rect: CGRect) { self = rect.standardized }
	@inlinable init(from: CGPoint, to: CGPoint) {
		self.init(standartizing: CGRect(from, (from - to).size))
	}
}

public extension CGRect {
	@inlinable static var infinity: CGRect {
		CGRect(.zero, .infinity)
	}
	
	@inlinable var isFinite   : Bool { size.isFinite }
	@inlinable var isZero     : Bool { size.isZero }
	@inlinable var isInfinite : Bool { !isFinite }
	@inlinable var isNotZero  : Bool { !isZero }
	@inlinable var finite     : CGRect? { isFinite ? self : nil }
	@inlinable var nonZero    : Self?   { isZero   ? nil : self }
	@inlinable var area       : CGFloat { standardized.size.area }
}

extension CGRect: ExpressibleByArrayLiteral {
	public init(arrayLiteral elements: CGFloat...) {
		self.init(
			elements.first  ?? .zero,
			elements.second ?? .zero,
			elements.third  ?? .zero,
			elements.fourth ?? .zero
		)
	}
}

public extension CGRect {
	@inlinable var topLeading       : CGPoint { origin }
	@inlinable var top              : CGPoint { CGPoint(midX, minY) }
	@inlinable var topTrailing      : CGPoint { CGPoint(maxX, minY) }
	@inlinable var leading          : CGPoint { CGPoint(minX, midY) }
	@inlinable var center           : CGPoint { CGPoint(midX, midY) }
	@inlinable var trailing         : CGPoint { CGPoint(maxX, midY) }
	@inlinable var bottomLeading    : CGPoint { CGPoint(minX, maxY) }
	@inlinable var bottom           : CGPoint { CGPoint(midX, maxY) }
	@inlinable var bottomTrailing   : CGPoint { CGPoint(maxX, maxY) }
	
	@inlinable var smallerSide : CGFloat { size.smallerSide }
	@inlinable var biggerSide  : CGFloat { size.biggerSide }
	
	@inlinable func clipped(from min: CGFloat, to max: CGFloat) -> CGSize {
		CGSize(width.clipped(from: min, to: max), height.clipped(from: min, to: max))
	}
	
	@inlinable func  width(scaled factor: Factor) -> CGFloat {  width.scaled(factor) }
	@inlinable func height(scaled factor: Factor) -> CGFloat { height.scaled(factor) }
}

public extension CGRect {
	@inlinable func inset(
		_      top: CGFloat,
		_  leading: CGFloat,
		_   bottom: CGFloat,
		_ trailing: CGFloat
	) -> CGRect {
		inset(
			by: UIEdgeInsets(
				   top: top,
				  left: leading,
				bottom: bottom,
				 right: trailing
			)
		)
	}
	
	/*
	func inset(_ edges: Edge.Set, _ value: CGFloat) -> CGRect {
		inset(edges.inset(.top, value), edges.inset(.leading, value), edges.inset(.bottom, value), edges.inset(.trailing, value))
	}
	*/
	
	@inlinable func inset(top        value: CGFloat) -> CGRect { inset(value, .zero, .zero, .zero) }
	@inlinable func inset(leading    value: CGFloat) -> CGRect { inset(.zero, value, .zero, .zero) }
	@inlinable func inset(bottom     value: CGFloat) -> CGRect { inset(.zero, .zero, value, .zero) }
	@inlinable func inset(trailing   value: CGFloat) -> CGRect { inset(.zero, .zero, .zero, value) }
	@inlinable func inset(horizontal value: CGFloat) -> CGRect { inset(.zero, value, .zero, value) }
	@inlinable func inset(vertical   value: CGFloat) -> CGRect { inset(value, .zero, value, .zero) }
	@inlinable func inset(_          value: CGFloat) -> CGRect { inset(value, value, value, value) }
}

public extension CGRect {
	@inlinable func offset(anchor: UnitPoint) -> CGRect {
		CGRect(origin.offset(in: size, from: anchor), size)
	}
	@inlinable func offset(_ x: CGFloat, _ y: CGFloat) -> CGRect {
		offsetBy(dx: x, dy: y)
	}
	@inlinable func offset(_ d: CGPoint)  -> CGRect { offset(d.x, d.y) }
	@inlinable func offset(_ d: CGSize)   -> CGRect { offset(d.point) }
	@inlinable func offset(_ v: CGVector) -> CGRect { offset(v.dx, v.dy) }
	@inlinable func offset(  x: CGFloat)  -> CGRect { offset(x, 0) }
	@inlinable func offset(  y: CGFloat)  -> CGRect { offset(0, y) }
}

public extension CGRect {
	@inlinable func offset(anchor: UnitPoint, factor: Factor) -> CGRect {
		CGRect(origin.offset(in: size, from: anchor, factor: factor.both), size)
	}
	@inlinable func offset(anchor: UnitPoint, factor: AxisFactor) -> CGRect {
		CGRect(origin.offset(in: size, from: anchor, factor: factor), size)
	}
	@inlinable func offset(_ x: CGFloat, _ y: CGFloat, factor: Factor) -> CGRect {
		offset(x.scaled(factor), y.scaled(factor))
	}
	@inlinable func offset(_ x: CGFloat, _ y: CGFloat, factor: AxisFactor) -> CGRect {
		offset(x.scaled(factor.horizontal), y.scaled(factor.vertical))
	}
	@inlinable func offset(_ point: CGPoint, factor: Factor) -> CGRect {
		offset(point.x, point.y, factor: factor)
	}
	@inlinable func offset(_ point: CGPoint, factor: AxisFactor) -> CGRect {
		offset(point.x, point.y, factor: factor)
	}
	@inlinable func offset(_ point: CGSize, factor: Factor) -> CGRect {
		offset(point.width, point.height, factor: factor)
	}
	@inlinable func offset(_ point: CGSize, factor: AxisFactor) -> CGRect {
		offset(point.width, point.height, factor: factor)
	}
	@inlinable func offset(_ point: CGVector, factor: Factor) -> CGRect {
		offset(point.dx, point.dy, factor: factor)
	}
	@inlinable func offset(_ point: CGVector, factor: AxisFactor) -> CGRect {
		offset(point.dx, point.dy, factor: factor)
	}
	@inlinable func xOffset(_ x: CGFloat, factor: Factor) -> CGRect {
		offset(x, 0, factor: factor)
	}
	@inlinable func yOffset(_ y: CGFloat, factor: Factor) -> CGRect {
		offset(0, y, factor: factor)
	}
}

public extension CGRect {
	@inlinable func  width(_  width: CGFloat) -> CGRect { CGRect(origin, CGSize(width, height)) }
	@inlinable func height(_ height: CGFloat) -> CGRect { CGRect(origin, CGSize(width, height)) }
}

public extension CGRect {
	@inlinable var s0: String { "(\(origin.s0), \(size.s0))" }
	@inlinable var s1: String { "(\(origin.s1), \(size.s1))" }
	@inlinable var s2: String { "(\(origin.s2), \(size.s2))" }
}

extension CGRect: Comparable {
	@inlinable public static func < (l: CGRect, r: CGRect) -> Bool { l.standardized.size.area < r.standardized.size.area }
}

// MARK: - Factor

public struct Factor:
	ExpressibleByFloatLiteral,
	ExpressibleByIntegerLiteral,
	ExpressibleByNilLiteral
{
	public typealias Value = CGFloat.FloatLiteralType
	
	public let value: Value
	@inlinable public var cg: CGFloat { CGFloat(value) }
	
	public init(		   	 _ value: Value)   { self.value = value }
	public init(  floatLiteral value: Value)   { self.value = value }
	public init(integerLiteral value: Int) 	   { self.value = Value(value) }
	public init(		   	 _ value: Int) 	   { self.value = Value(value) }
	public init(		   	 _ value: CGFloat) { self.value = Value(value) }
	public init(    nilLiteral value: ()) 	   { self.value = .one }
	
	public static let one: 	 	Factor = .init(Value.one)
	public static let zero: 	Factor = .init(Value.zero)
	public static let minusOne: Factor = .init(Value.minusOne)
	
	@inlinable public static func factor(_ value: Value) -> Factor { Factor(value) }
	@inlinable public var both: AxisFactor { .both(self) }
}

public struct AxisFactor:
	ExpressibleByFloatLiteral,
	ExpressibleByIntegerLiteral,
	ExpressibleByNilLiteral
{
	public let horizontal: Factor
	public let   vertical: Factor
	
	public init(_ horizontal: Factor, _ vertical: Factor) {
		self.horizontal = horizontal
		self.vertical = vertical
	}
	
	public init(horizontal: Factor) {
		self.horizontal = horizontal
		self.vertical = .one
	}
	
	public init(vertical: Factor) {
		self.horizontal = .one
		self.vertical = vertical
	}
	
	@inlinable public static func both(_ factor: Factor) -> AxisFactor { AxisFactor(factor) }
	public init(_ both: Factor) {
		self.horizontal = both
		self.vertical = both
	}
	
	@inlinable public static func x(_ factor: Factor) -> AxisFactor { AxisFactor(horizontal: factor) }
	@inlinable public static func y(_ factor: Factor) -> AxisFactor { AxisFactor(vertical: factor) }
	@inlinable public static func  width(_ factor: Factor) -> AxisFactor { AxisFactor(horizontal: factor) }
	@inlinable public static func height(_ factor: Factor) -> AxisFactor { AxisFactor(vertical: factor) }
	@inlinable public static func horizontal(_ factor: Factor) -> AxisFactor { .init(horizontal: factor) }
	@inlinable public static func   vertical(_ factor: Factor) -> AxisFactor { .init(vertical: factor) }

	@inlinable public init(  floatLiteral value: Factor.Value) 	{ self.init(.init(value)) }
	@inlinable public init(integerLiteral value: Int) 			{ self.init(.init(value)) }
	@inlinable public init(    nilLiteral value: ()) 			{ self.init(.one) }
}
