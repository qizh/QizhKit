//
//  BackendFetchState+alamofire.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 03.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

#if canImport(Alamofire)

import Alamofire

public extension BackendFetchState {
	@inlinable static func failed<T>(_ response: DataResponse<T, AFError>) -> Self {
		if case let .responseValidationFailed(.customValidationFailed(error)) = response.error,
		   let fetchError = error as? FetchError {
			return .failed(with: fetchError)
		}
		return .failed(with: .afError(response.debugDescription, response))
	}
}

public extension FetchError {
	var isNetworkError: Bool {
		providerError?.asAFError?.isNetworkError == true
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

public struct FetchErrorDebugDetails: Codable {
	public private(set) var fullname: String = "Unknown"
	public private(set) var description: String = "No description"
	public private(set) var details: [String] = .empty
	public private(set) var underlying: String? = .none
	public private(set) var af: AFResponseDebugDetails? = .none
	
	public init(of error: FetchError) {
		self.fullname = error.caseName
		self.description = error.localizedDescription
		
		switch error {
		case .afError(_, let response):
			self.af = FetchErrorDebugDetails.AFResponseDebugDetails(of: response)
		case .providerError(_, let underlyingError):
			self.underlying = underlyingError.localizedDescription
		case .error(let details):
			self.details = [details]
		case .multipleProvidersError(let details):
			self.details = details
		case .deleteError(let details):
			self.details = [details]
		case .contentError(let details):
			self.details = [details]
		case .verboseError(let title, let description):
			self.details = [title]
			if let description = description {
				self.details.append(description)
			}
		case .api(let code, let message):
			self.details = ["Code \(code)", message]
		case .appLogicError(let details):
			self.details = [details]
		
		case .preconditionValidation(.illegalCharacters(let value)):
			self.details = [value]
		
		case .sign(_): ()
		case .cancelled: ()
		case .notFound: ()
		case .unauthorized: ()
		case .unauthorizedCallPrevented: ()
		case .accessForbidden: ()
		case .emptyContentError: ()
		case .unknown: ()
		}
	}
	
	public struct AFResponseDebugDetails: Codable {
		public let request: String
		public let requestBody: String
		public let responseCode: Int?
//		public let responseHeaders: [String: String]?
		public let responseBody: String
//		public let data: String
//		public let networkDuration: String
//		public let serializationDuration: String
		public let result: String?
		public let underlying: AFErrorDebugDetails?
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
			
			if let error = response.underlying?.asAFError {
				self.underlying = .init(error)
				self.error = nil
			} else {
				self.underlying = nil
				self.error = response.underlying?.localizedDescription
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
