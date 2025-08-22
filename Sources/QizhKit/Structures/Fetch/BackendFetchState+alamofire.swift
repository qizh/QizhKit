//
//  BackendFetchState+alamofire.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

#if canImport(Alamofire)

@preconcurrency import Alamofire

extension DataResponse where Failure == AFError {
	public var fetchError: FetchError {
		switch error {
		case .responseValidationFailed(.customValidationFailed(let fetchError as FetchError)):
			return fetchError
		case .responseValidationFailed(.customValidationFailed(let validationError)):
			return .providerError("Known response validation error", validationError)
		default:
			return .afError(error?.localizedDescription ?? "Unknown error", self)
		}
	}
}

extension BackendFetchState {
	@inlinable
	public static func failed<T>(_ response: DataResponse<T, AFError>) -> Self {
		.failed(with: response.fetchError)
	}
}

public extension FetchError {
	var afError: AFError? {
		switch self {
		case .providerError(_, let error):
			if let fetchError = error as? FetchError {
				return fetchError.afError
			}
			return error.asAFError
		case .afError(_, let response):
			return response.underlying?.asAFError
		default:
			return .none
		}
	}
	
	var isNetworkError: Bool {
		afError?.isNetworkError == true
	}
}

public extension AFError {
	var isNetworkError: Bool {
		switch self {
		case .serverTrustEvaluationFailed: 	fallthrough // by ServerTrustEvaluating
		case .sessionDeinitialized: 		fallthrough // by Session
		case .sessionInvalidated: 			fallthrough // by URLSession
		case .sessionTaskFailed: 			return true	// by URLSessionTask
		default: 							return false
		}
	}
}

extension DataResponse: FetchResponse {
	public var valueDescription: String? { value.map { "\($0)" } ?? nil }
	public var underlying: Error? { error }
}

public protocol DebugDetailsProvidingError {
	var debugDetails: [String: any Sendable] { get }
}

public struct FetchErrorDebugDetails: Codable, Sendable {
	public private(set) var type: String? = .none
	public private(set) var description: String = "No description"
	@CodableAnyDictionary public private(set) var details: [String: any Sendable] = .empty
	@CodableAnyDictionary public private(set) var underlying: [String: any Sendable] = .empty
	public private(set) var af: AFResponseDebugDetails? = .none
	
	public init(of error: Error) {
		switch error {
		case let fetchError as FetchError:
			self = Self(of: fetchError)
		default:
			self.type = caseName(of: error, [.type, .name])
			self.description = error.localizedDescription
		}
	}
	
	public init(of error: FetchError) {
		self.type = caseName(of: error, [.type, .name])
		self.description = error.localizedDescription
		
		switch error {
		case .afError(let details, let response):
			self.af = FetchErrorDebugDetails.AFResponseDebugDetails(of: response)
			self.details = ["note": details]
		case .providerError(_, let fetchError as FetchError):
			self.underlying = FetchErrorDebugDetails(of: fetchError).asDictionary()
		case .providerError(_, let detailedError as DebugDetailsProvidingError):
			self.underlying = detailedError.debugDetails
		case .providerError(_, let generalError):
			self.underlying = [
				"description": generalError.localizedDescription
			]
		case .error(let details):
			self.details = ["note": details]
		case .multipleProvidersError(let details):
			self.details = ["notes": details]
		case .deleteError(let details):
			self.details = ["note": details]
		case .contentError(let details):
			self.details = ["note": details]
		case .verboseError(let title, let description):
			self.details = [
				"title": title,
				"description": description
			]
		case .api(let code, let message):
			self.details = [
				"code": code,
				"message": message
			]
		case let .appLogicError(statement, reason, function, file, line):
			self.details = [
				"statement": statement,
				"reason": reason,
				"function": function,
				"file": file,
				"line": line
			]
		case .preconditionValidation(.illegalCharacters(let value)):
			self.details = [
				"type": "illegalCharacters",
				"value": value
			]
		case let .preconditionValidation(.missingInput(input, details)):
			self.details = [
				"type": "missingInput",
				"input": input,
				"details": details,
			]
		case .preconditionValidation(.missingAuthentication):
			self.details = [
				"type": "missingAuthentication"
			]
		case .sign(let reason):
			self.details = [
				"reason": reason.caseWord
			]
			if case .userExists(let loginMethod) = reason {
				self.details["login method"] = loginMethod.caseWord
			}
		case .priceMismatch(let message):
			self.details = [
				"message": message
			]
		case .cancelled: ()
		case .paymentFailed: ()
		case .notFound: ()
		case .unauthorized: ()
		case .unauthorizedCallPrevented: ()
		case .accessForbidden: ()
		case .emptyContentError: ()
		case .unknown: ()
		case .passwordResetTokenExpired: ()
		case .notImplemented: ()
		case let .doubleErrors(le as FetchError, re as FetchError):
			self.underlying = [
				"1": FetchErrorDebugDetails(of: le).description,
				"2": FetchErrorDebugDetails(of: re).description,
			]
		case let .doubleErrors(le as DebugDetailsProvidingError, re as DebugDetailsProvidingError):
			self.underlying = [
				"1": le.debugDetails,
				"2": re.debugDetails,
			]
		case .doubleErrors(_, let e as FetchError),
			 .doubleErrors(let e as FetchError, _):
			self.underlying = FetchErrorDebugDetails(of: e).asDictionary()
		case .doubleErrors(_, let e as DebugDetailsProvidingError),
			 .doubleErrors(let e as DebugDetailsProvidingError, _):
			self.underlying = e.debugDetails
		case .doubleErrors(let le, let re):
			self.underlying = [
				"description": [
					"1": le.localizedDescription,
					"2": re.localizedDescription,
				]
			]

		}
	}
	
	public struct AFResponseDebugDetails: Codable, Sendable {
		public let request: String
		public let requestBody: String
		public let responseCode: Int?
//		public let responseHeaders: [String: String]?
		public let responseBody: String
//		public let data: String
//		public let networkDuration: String
//		public let serializationDuration: String
		public let result: String?
		@CodableAnyDictionary public var underlying: [String: any Sendable]
		public let error: String?

		init(of response: FetchResponse) {
			self.request = response.request
				.map { "\($0.httpMethod!) \($0)" }
				?? "nil"
			self.requestBody = response.request?.httpBody
				.map { String(decoding: $0, as: UTF8.self) }
				?? "None"
			self.responseCode = response.response?.statusCode
//			self.responseHeaders = response.response?.headers.sorted().dictionary
			self.responseBody = response.data
				.map { String(decoding: $0, as: UTF8.self) }
				?? "None"
//			self.data = response.data?.description ?? "None"
//			self.networkDuration = response.metrics
//				.map { "\($0.taskInterval.duration)s" }
//				?? "None"
//			self.serializationDuration = "\(response.serializationDuration) s"
			self.result = response.valueDescription
			
			switch response.underlying {
			case let error as AFError:
				self.underlying = AFErrorDebugDetails(error).asDictionary()
				self.error = .none
			case let error as FetchError:
				self.underlying = FetchErrorDebugDetails(of: error).asDictionary()
				self.error = .none
			case .some(let error):
				self.error = error.localizedDescription
			case .none:
				self.error = .none
			}
		}
		
		public struct AFErrorDebugDetails: Codable {
			let description: String
			let reason: String?
			let underlying: String?
			
			init(_ error: AFError) {
				self.description = error.localizedDescription
				self.underlying = error.underlyingError?.localizedDescription
				self.reason = error.failureReason
			}
		}
	}
}

public extension FetchError {
	var debugDetails: FetchErrorDebugDetails {
		FetchErrorDebugDetails(of: self)
	}
}

#else

// MARK: Fallback

public extension FetchError {
	var isNetworkError: Bool { false }
}

#endif
