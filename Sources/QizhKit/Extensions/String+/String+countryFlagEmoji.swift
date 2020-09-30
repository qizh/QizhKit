//
//  String+countryFlagEmoji.swift
//  
//
//  Created by Serhii Shevchenko on 30.09.2020.
//

import Foundation

public extension Unicode.Scalar {
	static let regionalIndicator: Self = Unicode.Scalar(UInt32(127397)).forceUnwrapBecauseCreated()
}

public extension String {
	@inlinable var countryCodeToFlagEmoji: String {
		 unicodeScalars
		.map { $0.value + Unicode.Scalar.regionalIndicator.value }
		.compactMap(Unicode.Scalar.init)
		.map(String.init)
		.joined()
	}
	
	@inlinable var flagEmojiToCountryCode: String {
		 unicodeScalars
		.map { $0.value - Unicode.Scalar.regionalIndicator.value }
		.compactMap(Unicode.Scalar.init)
		.map(String.init)
		.joined()
	}
}
