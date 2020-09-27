//
//  String+phone.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 01.09.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation
import PhoneNumberKit

public extension String {
	func formattedPhoneNumber(of countryCode: String? = Locale.current.regionCode) -> String {
		print("* Format Phone Number")
		let trimmed = withSpacesTrimmed
		print("\t < input: `\(trimmed)`")
		if let inputText = trimmed.nonEmpty {
			var phoneNumber: PhoneNumber? = .none
			
			/// Try to parse for **input country**
			if let code = countryCode {
				print("\t < trying to parse as a \(code) number")
				let phoneNumberKit = PhoneNumberKit()
				do {
					phoneNumber = try phoneNumberKit
						.parse(
							inputText,
							withRegion: code,
							ignoreType: true
						)
					print("\t > succeed")
				} catch {
					print("\t <! failed: \(error.localizedDescription)")
				}
				
				if let parsed = phoneNumber {
					let formatted = phoneNumberKit.format(parsed, toType: .international)
					
					print("\t > formatted from `\(inputText)` to `\(formatted)`")
					return formatted
				}
			}
			
			print("\t >! failed to parse")
			return trimmed
		}
		print("\t >! empty input")
		return trimmed
	}
}
