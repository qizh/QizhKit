//
//  Date+RawRepresentable.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.01.2023.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Date: /* @retroactive */ RawRepresentable {
	public init?(rawValue: String) {
		if let value = Double(rawValue) {
			self.init(timeIntervalSinceReferenceDate: value)
		} else {
			return nil
		}
	}
	
	public var rawValue: String {
		timeIntervalSinceReferenceDate.s0
	}
}
