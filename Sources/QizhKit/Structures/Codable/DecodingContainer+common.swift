//
//  Codable+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension KeyedDecodingContainer {
	func decodeIfPresent(_ type: URL.Type, forKey key: Key) throws -> URL? {
		if let text = try? decodeIfPresent(String.self, forKey: key) {
			if let url = URL(string: text) {
				return url
			}
			
			if
				let encodedText = text.addingPercentEncoding(
					withAllowedCharacters: .urlQueryAllowed
				),
				let url = URL(string: encodedText)
			{
				return url
			}
		}
		return nil
	}
}
