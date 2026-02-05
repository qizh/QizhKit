//
//  DynamicTypeSize+interpolate.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 16.02.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Cases

extension DynamicTypeSize {
	public static let allRegularCases: [DynamicTypeSize] = allCases(in: .regularRange)
	
	@inlinable public static func allCases(
		from start: DynamicTypeSize,
		to end: DynamicTypeSize
	) -> [DynamicTypeSize] {
		allCases(in: start ... end)
	}
	
	@inlinable public static func allCases(
		in range: ClosedRange<DynamicTypeSize>
	) -> [DynamicTypeSize] {
		allCases.filter(range.contains(_:))
	}
}

extension RangeExpression where Self == ClosedRange<DynamicTypeSize> {
	/// This range spans from `.xSmall` through `.xxxLarge`, covering the regular
	/// content size categories and excluding the accessibility sizes
	///
	/// Use this when you want to:
	/// - Iterate over or filter the regular Dynamic Type cases.
	/// - Compute progress or interpolate values across standard sizes
	///   (e.g., for layout or typography scaling), in combination with helpers
	///   like `DynamicTypeSize.progress(in:)` or `ClosedRange.interpolated(for:from:)`.
	///
	/// - Note: The following accessibility sizes are excluded.
	///   ```swift
	///   .accessibility1 ... .accessibility5
	///   ```
	///
	/// - SeeAlso:
	///   - `fullRange` for a range that includes accessibility sizes.
	///   - `DynamicTypeSize.allRegularCases` for an array of all regular cases.
	public static var regularRange: ClosedRange<DynamicTypeSize> {
		.xSmall ... .xxxLarge
	}
	
	/// A range that spans from `.xSmall` through `.accessibility5`, covering
	/// every `DynamicTypeSize` case, including the accessibility sizes.
	/// 
	/// Use this when you want to:
	/// - Iterate over or filter all Dynamic Type cases, including accessibility.
	/// - Compute progress or interpolate values across the entire spectrum,
	///   in combination with helpers like `DynamicTypeSize.progress(in:)`
	///   or `ClosedRange.interpolated(for:from:)`.
	/// - Ensure UI scales appropriately even for the largest accessibility sizes.
	/// 
	/// - Note:
	///   ```swift
	///   .accessibility1 ... .accessibility5
	///   ```
	///   These accessibility sizes represent significantly larger text
	///   and may require layout considerations.
	///
	/// - SeeAlso:
	///   - `regularRange` for a range that excludes accessibility sizes.
	///   - `DynamicTypeSize.allCases` for an array of all cases.
	public static var fullRange: ClosedRange<DynamicTypeSize> {
		.xSmall ... .accessibility5
	}
}

extension RangeExpression where Bound: CaseIterable {
	@inlinable public var cases: [Bound] {
		Bound.allCases.filter(self.contains(_:))
	}
}

// MARK: Range + interpolated

extension ClosedRange where Bound: BinaryFloatingPoint {
	public func interpolated(at progress: Bound) -> Bound {
		lowerBound + (upperBound - lowerBound) * progress
	}
	
	@inlinable public func interpolated<R>(
		for size: DynamicTypeSize,
		from sizes: R = .regularRange
	) -> Bound
		where R: RangeExpression,
			  R.Bound == DynamicTypeSize
	{
		self.interpolated(at: size.progress(in: sizes))
	}
}

// MARK: Type + Interpolate

extension DynamicTypeSize {
	public func interpolate<R, F>(
		_ range: ClosedRange<F>,
		from types: R
	) -> F
		where R: RangeExpression,
			  R.Bound == DynamicTypeSize,
			  F: BinaryFloatingPoint
	{
		range.interpolated(at: self.progress(in: types))
	}
	
	public func progress<R, F>(in range: R = .regularRange) -> F where R: RangeExpression, R.Bound == DynamicTypeSize, F: BinaryFloatingPoint {
		let cases = range.contains(self) ? range.cases : DynamicTypeSize.allCases
		let currentIndex = cases.firstIndex(of: self).forceUnwrapBecauseTested()
		return F(currentIndex) / F(cases.count)
	}
}

// MARK: ID + Case Name

extension DynamicTypeSize: @retroactive Identifiable {
	@inlinable public var id: String { caseName }
	public var caseName: String {
		switch self {
		case .xSmall: 			"XS"
		case .small: 			"S"
		case .medium: 			"M"
		case .large: 			"L"
		case .xLarge: 			"XL"
		case .xxLarge: 			"XXL"
		case .xxxLarge: 		"XXXL"
		case .accessibility1: 	"A1"
		case .accessibility2: 	"A2"
		case .accessibility3: 	"A3"
		case .accessibility4: 	"A4"
		case .accessibility5: 	"A5"
		@unknown default: 		"?"
		}
	}
}
