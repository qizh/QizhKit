//
//  Airtable+coding.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 02.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension DateFormatter {
	static let airtable: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSSZ"
		formatter.calendar = Calendar(identifier: .iso8601)
		formatter.timeZone = TimeZone(abbreviation: "UTC") // TimeZone(secondsFromGMT: 0)
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
}

public extension JSONEncoder {
	static let airtable: JSONEncoder = {
		let encoder = JSONEncoder()
		encoder.outputFormatting = .prettyPrinted
		encoder.dateEncodingStrategy = .formatted(.airtable)
		return encoder
	}()
}

public extension JSONDecoder {
	static let airtable: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(.airtable)
		return decoder
	}()
	
	static let rails: JSONDecoder = {
		let decoder = JSONDecoder()
		decoder.dateDecodingStrategy = .formatted(.airtable)
		return decoder
	}()
}
