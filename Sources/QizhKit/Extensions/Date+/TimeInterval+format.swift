//
//  TimeInterval+format.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 21.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension TimeInterval {
	/// Formats a string
	/// - Parameters:
	///   - units: Units to have in output
	///   - style: Unit names to show
	///   - same: Zero formatting behaviour
	///   - isRough: Includes approximation phrase like "About"
	///   - isRemaining: Includes time remaining phrase like "30 minutes remaining"
	///   - context: Position in a sentence
	func format(
		using units: NSCalendar.Unit,
		style: DateComponentsFormatter.UnitsStyle = .full,
		same: DateComponentsFormatter.ZeroFormattingBehavior = .dropAll,
		isRough: Bool = false,
		isRemaining: Bool = false,
		context: Formatter.Context = .unknown
	) -> String? {
		let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = same
		formatter.includesApproximationPhrase = isRough
		formatter.includesTimeRemainingPhrase = isRemaining
		formatter.formattingContext = context
        return formatter.string(from: self)
	}
}
