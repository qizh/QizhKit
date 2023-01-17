//
//  DataResponse+debug.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.06.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation

#if canImport(Alamofire)
import Alamofire

// MARK: Debug Description

extension DataResponse {
	/// - Parameters:
	///   - debugDepth: Description depth
	///   - shouldFormat: Format json responce
	/// - Returns: Request and response description
	public func debugDescription(
		depth debugDepth: DebugDepth,
		format shouldFormat: Bool = false
	) -> String {
		guard debugDepth.is(not: .none) else {
			return "[Result]: \(result.caseName)"
		}
		
		guard let request = request else {
			return """
			[Request]: None
			[Result]: \(result.caseName)
			"""
		}
		
		let jsonType = "json"
		let printableTypes = [jsonType, "xml", "text", "form-urlencoded", "graphql"]
		
		// MARK: Request
		
		let requestBodyDescription: String
		if let data = request.httpBody, !data.isEmpty {
			let contentType = request.headers.contentType ?? .empty
			let isPrintableType = printableTypes
				.contains { type in
					contentType.contains(type)
				}
			
			if isPrintableType, data.count <= debugDepth.maxDataCount {
				requestBodyDescription = """
				[Body]:
					\(String(decoding: data, as: UTF8.self)
						.withLinesNSpacesTrimmed
						.tabOffsettingNewLines())
				"""
			} else {
				requestBodyDescription = debugDepth > .minimum ? "[Body]: \(data.count) bytes" : .empty
			}
		} else {
			requestBodyDescription = debugDepth > .minimum ? "[Body]: None" : .empty
		}
		
		var requestDescription: String = "[Request]: \(request.httpMethod!) \(request)"
		if debugDepth > .minimum, not(request.headers.isEmpty) {
			requestDescription += .newLine + """
				[Headers]:
					\("\(request.headers.sorted())".tabOffsettingNewLines(by: 2))
			"""
		}
		if requestBodyDescription.isNotEmpty {
			requestDescription += .newLine + """
				\(requestBodyDescription.tabOffsettingNewLines())
			"""
		}
		
		// MARK: Response
		
		let responseDescription = response.map { response in
			let responseBodyDescription: String
			if let data = data, !data.isEmpty {
				let responseContentType = response.headers.contentType.orEmpty.lowercased()
				let isPrintableType = printableTypes
					.contains { type in
						responseContentType.contains(type)
					}
				
				if data.count <= debugDepth.maxDataCount, isPrintableType {
					if shouldFormat, responseContentType.contains(jsonType) {
						var serializationOptions: JSONSerialization.ReadingOptions = .fragmentsAllowed
						if #available(iOS 15.0, *) {
							serializationOptions.insert(.json5Allowed)
						}
						do {
							let json = try JSONSerialization
								.jsonObject(with: data, options: serializationOptions)
							
							let formattedJsonData = try JSONSerialization.data(
								withJSONObject: json,
								options: [.prettyPrinted, .withoutEscapingSlashes]
							)
							let dataString = formattedJsonData.asString(encoding: .utf8).orEmpty
							responseBodyDescription = """
							[Body]: (formatted)
								\(dataString.tabOffsettingNewLines())
							"""
						} catch {
							let dataString = String(decoding: data, as: UTF8.self)
								.withLinesNSpacesTrimmed
							responseBodyDescription = """
							[Body]: (json formatting failed)
								\(dataString.tabOffsettingNewLines())
							"""
						}
					} else {
						let dataString = String(decoding: data, as: UTF8.self)
							.withLinesNSpacesTrimmed
						responseBodyDescription = """
						[Body]:
							\(dataString.tabOffsettingNewLines())
						"""
					}
				} else {
					responseBodyDescription = debugDepth > .minimum ? "[Body]: \(data.count) bytes" : .empty
				}
			} else {
				responseBodyDescription = debugDepth > .minimum ? "[Body]: None" : .empty
			}
			
			var description = ""
			if debugDepth > .minimum || response.statusCode != 200 {
				description += """
					[Status Code]: \(response.statusCode)
				"""
			}
			if debugDepth > .minimum {
				if description.isNotEmpty {
					description += .newLine
				}
				description += """
					[Headers]:
						\("\(response.headers.sorted())".tabOffsettingNewLines(by: 2))
				"""
			}
			if responseBodyDescription.isNotEmpty {
				if description.isNotEmpty {
					description += .newLine
				}
				description += """
					\(responseBodyDescription.tabOffsettingNewLines())
				"""
			}
			if description.isNotEmpty {
				description = "[Response]:" + .newLine + description
			}
			return description
		} ?? (
			debugDepth > .minimum
				? "[Response]: None"
				: .empty
		)
		
		// MARK: All together
		
		var output = requestDescription
		if responseDescription.isNotEmpty {
			output += .newLine + responseDescription
		}
		
		if debugDepth > .minimum {
			let networkDuration = metrics.map { "\($0.taskInterval.duration)s" } ?? "None"
			output += .newLine + "[Network Duration]: \(networkDuration)"
		}
		
		if debugDepth > .default {
			output += .newLine + "[Serialization Duration]: \(serializationDuration)s"
		}
		
		let resultOutput = debugDepth > .default
			? "\(result)"
			: result.caseName
		
		output += .newLine + "[Result]: \(resultOutput)"
		
		return output
	}
}

extension HTTPHeaders {
	@inlinable
	public var contentType: String? {
		value(for: "Content-Type")
	}
}
#endif
