//
//  Locale+shortcuts.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 18.11.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Locale {
	/// [ISO 3166-1](https://en.wikipedia.org/wiki/ISO_3166-1) two-letter country (region) code
	/// for the locale, if available and has a length of two.
	///
	/// This property extracts the region code in the two-letter format
	/// from the locale's region information.
	///
	/// For example, for a locale
	/// representing **United States**, it would return `"US"`,
	/// while for **France** it would return `"FR"`.
	///
	/// ### Exuivalent to
	/// ```swift
	/// locale.region?.identifier.pair
	/// ```
	///
	/// - Returns: `nil` if the region code cannot be determined
	/// 	or is not available in the two-letter format.
	@inlinable public var countryCode: String? {
		region?.identifier.pair
	}
	
	/// [ISO 639-1](https://en.wikipedia.org/wiki/ISO_639-1) two-letter language code
	/// for the locale, if available.
	///
	/// This property extracts the language code
	/// in the two-letter ([alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2)) format
	/// from the locale's language information.
	/// 
	/// For example, for a `locale`
	/// representing **English**, it would return `"en"`,
	/// while for **French** it would return `"fr"`.
	///
	/// ### Exuivalent to
	/// ```swift
	/// locale.language.languageCode?.identifier(.alpha2)
	/// ```
	///
	/// - Returns: `nil` if the language code cannot be determined
	/// 	or is not available in the alpha-2 format.
	@inlinable public var languageCode: String? {
		language.languageCode?.identifier(.alpha2)
	}
}
