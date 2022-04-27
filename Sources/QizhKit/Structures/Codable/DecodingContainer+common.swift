//
//  Codable+.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension KeyedDecodingContainer {
	public func decodeIfPresent(_ type: URL.Type, forKey key: Key) throws -> URL? {
		if let text = try? decodeIfPresent(String.self, forKey: key) {
			var result: URL
			
			if let url = URL(string: text) {
				result = url
			} else if
				let encodedText = text.addingPercentEncoding(
					withAllowedCharacters: .urlFragmentAllowed
				),
				let url = URL(string: encodedText)
			{
				result = url
			} else {
				return nil
			}
			
			if result.scheme.isNotSet,
			   let updated = URL(string: "http://" + result.absoluteString)
			{
				result = updated
				/*
				var components = URLComponents(url: result, resolvingAgainstBaseURL: true)
				components?.scheme = "http"
				if let updated = components?.url {
					result = updated
				}
				*/
			}
			
			return result
		}
		return nil
	}
	
	public func decode(_ type: URL.Type, forKey key: Key) throws -> URL {
		if let url = try? decodeIfPresent(URL.self, forKey: key) {
			return url
		} else {
			throw DecodingError.dataCorruptedError(
				forKey: key,
				in: self,
				debugDescription: "Invalid or no URL string"
			)
		}
	}
}
