//
//  Locale+shortcuts.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 18.11.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Locale {
	/// Region identifier with length of two
	///
	/// ### Exuivalent to
	/// ```swift
	/// locale.region?.identifier.pair
	/// ```
	@inlinable public var countryCode: String? {
		region?.identifier.pair
	}
}
