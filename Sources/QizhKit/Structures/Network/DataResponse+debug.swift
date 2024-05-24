//
//  DataResponse+debug.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.06.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import Foundation
import os.log

#if canImport(Alamofire)
import Alamofire

// MARK: Debug Description

extension DataResponse {
	/// - Parameters:
	///   - debugDepth: Description depth
	///   - shouldFormat: Format json responce
	/// - Returns: Request and response description
	public func debugDescription(
		depth debug: DebugDepth,
		format shouldFormat: Bool = false
	) -> String {
		let debugDepth: DebugDepth
		if case .failure = result {
			debugDepth = .extra
		} else {
			debugDepth = debug
		}
		
		guard let request = request else {
			return """
			[Request]: None
			[Result]: \(result.caseName)
			"""
		}
		
		guard debugDepth.is(not: .none) else {
			/// `debugDepth` won't be `.none` for `.failure` `result`
			return "Successfully called \(request.httpMethod!) \(request)"
			/*
			return """
			[Request]: \(request.httpMethod!) \(request)
			[Result]: \(result.caseName)
			"""
			*/
		}
		
		let jsonType = "json"
		let printableTypes = [jsonType, "xml", "text", "form-urlencoded", "graphql"]
		
		/*
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
		*/
		
		let requestDescription = request.debugDescription(depth: debugDepth)
		
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
							
							if not(JSONSerialization.isValidJSONObject(json)) {
								throw FetchError.contentError("Invalid JSON object")
							}
							
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
		
		if debugDepth > .minimum || metrics?.taskInterval.duration > 1 {
			let networkDuration = metrics.map { "\($0.taskInterval.duration, f: 3)s" } ?? "None"
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
	/// Value for the `Content-Type` header
	@inlinable public var contentType: String? {
		value(for: "Content-Type")
	}
}

// MARK: Logger shortcut

extension Logger {
	/// Will log the `debugDescription` with `response.result.logType` log level
	/// - Parameters:
	///   - response: Alamofire's `DataResponse`
	///   - debug: Debug level
	///   - format: Set if you need to format the json output,
	///   			in other case will format when `debug > .minimum`
	public func logDebugDescription <Success, Failure: Error> (
		of response: DataResponse<Success, Failure>,
		debug: DebugDepth,
		format: Bool? = .none
	) {
		let doFormat = if let format {
			format
		} else {
			debug > .minimum
		}
		
		response.debugDescription(depth: debug, format: doFormat)
			.forEachLoggerChunk {
				self.log(level: response.result.logType, "\($0)")
			}
	}
	
	/// Will call ``logDebugDescription(of:debug:format:)`` when `debug.isOn`
	/// - Parameters:
	///   - response: Alamofire's `DataResponse`
	///   - debug: Debug level
	///   - format: Set if you need to format the json output,
	///   			in other case will format when `debug > .minimum`
	@inlinable public func logDebugDescriptionIfNeeded <Success, Failure: Error> (
		of response: DataResponse<Success, Failure>,
		debug: DebugDepth,
		format: Bool? = .none
	) {
		if debug.isOn {
			logDebugDescription(of: response, debug: debug, format: format)
		}
	}
}
#endif

// MARK: Log type of result

extension Result {
	/// `.debug` for `.success`, `.error` for `.failure`
	@inlinable public var logType: OSLogType {
		switch self {
		case .success(_): return .debug
		case .failure(_): return .error
		}
	}
}

// MARK: HTTPURLResponse

extension HTTPURLResponse {
	public func debugDescription(
		depth debugDepth: DebugDepth
	) -> String {
		let responseBodyDescription: String
		var description = ""
		if debugDepth > .minimum || statusCode != 200 {
			description += """
				[Status Code]: \(statusCode)
			"""
		}
		if debugDepth > .minimum {
			if description.isNotEmpty {
				description += .newLine
			}
			description += """
				[Headers]:
					\("\(headers.sorted())".tabOffsettingNewLines(by: 2))
			"""
		}
		
		if description.isNotEmpty {
			description = "[Response]:" + .newLine + description
		}
		return description
	}
}
