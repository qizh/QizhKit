//
//  URLRequest+debug.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.02.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension URLRequest {
	public func debugDescription(
		depth debugDepth: DebugDepth
	) -> String {
		let printableTypes = ["json", "xml", "text", "form-urlencoded", "graphql"]
		
		let bodyDescription: String
		if let data = httpBody, !data.isEmpty {
			let contentType = headers.contentType ?? .empty
			let isPrintableType = printableTypes
				.contains { type in
					contentType.contains(type)
				}
			
			if isPrintableType, data.count <= debugDepth.maxDataCount {
				bodyDescription = """
				[Body]:
					\(String(decoding: data, as: UTF8.self).withLinesNSpacesTrimmed, offset: .tab)
				"""
			} else {
				bodyDescription = debugDepth > .minimum ? "[Body]: \(data.count) bytes" : .empty
			}
		} else {
			bodyDescription = debugDepth > .minimum ? "[Body]: None" : .empty
		}
		
		var description: String = "[Request]: \(self.httpMethod!) \(self)"
		if debugDepth > .minimum, not(headers.isEmpty) {
			description += .newLine + """
				[Headers]:
					\(headers.sorted().description, offset: .tabs(2))
			"""
		}
		if description.isNotEmpty {
			description += .newLine + """
				\(bodyDescription, offset: .tab)
			"""
		}
		
		return description
	}
}
