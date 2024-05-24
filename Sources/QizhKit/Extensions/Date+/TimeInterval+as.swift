//
//  TimeInterval+as.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.02.2023.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: TimeInterval + as

extension TimeInterval {
	public func asDateRange(from date: Date = .now) -> Range<Date> {
		date ..< date.addingTimeInterval(self)
	}
}

@available(iOS 16.0, *)
extension TimeInterval {
	public func asDuration() -> Duration {
		Duration.seconds(self)
	}
}
