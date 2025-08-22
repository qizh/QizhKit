//
//  Clamped.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 05.01.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// Will auto-limit the value in the provided
///
/// - Experiment:
/// ``` swift
/// func getMessages(
///   @Clamped(range: 1...100) limit: UInt = 10
/// ) -> [Message] {
///   /// `limit` will always be in the range of 1...100
///   /// even if other value is provided
/// }
/// ```
@propertyWrapper
public struct Clamped<Value: Comparable> {
	private var value: Value
	private let range: ClosedRange<Value>
	
	/// Value always in the ``range`` provided
	public var wrappedValue: Value {
		get { value }
		set { value = min(max(newValue, range.lowerBound), range.upperBound) }
	}
	
	/// Will auto-limit the value in the provided
	///
	/// - Parameters:
	///   - wrappedValue: Comparable value to be Clamped (limited to a range)
	///   - range: Range to limit the value
	///
	/// - Experiment:
	/// ``` swift
	/// func getMessages(
	///   @Clamped(range: 1...100) limit: UInt = 10
	/// ) -> [Message] {
	///   /// `limit` will always be in the range of 1...100
	///   /// even if other value is provided
	/// }
	/// ```
	public init(wrappedValue: Value, range: ClosedRange<Value>) {
		self.range = range
		self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
	}
}
