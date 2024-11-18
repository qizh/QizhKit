//
//  File.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 18.11.2024.
//

import Foundation

extension Locale {
	/// Region identifier with length of two
	///
	/// ### Exuivalent to
	/// ```swift
	/// locale.region?.identifier.pair
	/// ```
	public var countryCode: String? {
		region?.identifier.pair
	}
}
