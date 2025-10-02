//
//  LocalizedStringResource+update.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.10.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

public import Foundation

extension LocalizedStringResource {
	@inlinable public func withUpdated(locale: Locale) -> LocalizedStringResource {
		var copy = self
		copy.locale = locale
		return copy
	}
}
