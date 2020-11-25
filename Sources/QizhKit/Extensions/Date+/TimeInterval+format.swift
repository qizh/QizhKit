//
//  TimeInterval+format.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 21.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension TimeInterval {
	func format(
		using units: NSCalendar.Unit,
		style: DateComponentsFormatter.UnitsStyle = .full,
		same: DateComponentsFormatter.ZeroFormattingBehavior = .dropAll,
		isRough: Bool = false,
		isRemaining: Bool = false
	) -> String? {
		let formatter = DateComponentsFormatter()
        formatter.allowedUnits = units
        formatter.unitsStyle = style
        formatter.zeroFormattingBehavior = same
		formatter.includesApproximationPhrase = isRough
		formatter.includesTimeRemainingPhrase = isRemaining
        return formatter.string(from: self)
	}
}
