//
//  Fetcher.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 11.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine
#if canImport(Alamofire)
import Alamofire
#endif

// MARK: Fetcher

public protocol Fetcher: ObservableObject {
	associatedtype Value: Codable, Equatable
	var state: BackendFetchState<Value> { get set }
	var debug: Bool { get set }
	init()
}

public protocol GeneralFetchStatePublishing {
	var basicStatePublisher: GeneralStatePublisher { get }
	// var basicStatePublisher: AnyPublisher<GeneralBackendFetchState, Never> { get }
}

public struct FetcherParametersKeys {
	public static let formula = "filterByFormula"
	public static let records = "records"
	public static let maxRecords = "maxRecords"
	public static let authorization = "Authorization"
	public static let bearer = "Bearer"
}

public extension Fetcher {
	typealias F = AirtableFormulaBuilder
	typealias Key = FetcherParametersKeys
	typealias State = BackendFetchState<Value>
	
	@inlinable func e(_ value: String) -> String {
		value.withApostrophesEscaped
	}
	
	#if DEBUG
	@inlinable static var demoInProgress: Self { demo(.inProgress) }
	@inlinable static var demoFailed: Self { demo(.failed("Demo failure")) }
	static func demo(_ state: State) -> Self {
		let fetcher = Self()
		fetcher.state = state
		return fetcher
	}
	#endif
}

// MARK: Debug Control

public enum DebugDepth: Comparable, EasyCaseComparable {
	case none
	case minimum
	case `default`
	case extra
	
	public var maxDataCount: Int {
		switch self {
		case .none: 	return 0
		case .minimum: 	return 500
		case .default: 	return 5_000
		case .extra: 	return .max
		}
	}
}

// MARK: Single Protocol

public protocol SingleItemFetcher: Fetcher {
	#if DEBUG
	static var demoData: Value { get }
	#endif
}

// MARK: Collection Protocol

#if DEBUG
public protocol CollectionFetcher: Fetcher, ExpressibleByArrayLiteral
	where
	Value: RandomAccessCollection,
	Value: InitializableCollection,
	Value: InitializableWithSequenceCollection,
	Value: EmptyTestable,
	Value.Element: Codable
{
	#if DEBUG
	static var demoData: [Value.Element] { get }
	#endif
}
#else
public protocol CollectionFetcher: Fetcher
	where
	Value: RandomAccessCollection,
	Value: InitializableCollection,
	Value: InitializableWithSequenceCollection,
	Value: EmptyTestable,
	Value.Element: Codable
{
	#if DEBUG
	static var demoData: [Value.Element] { get }
	#endif
}
#endif

// MARK: Publishable

public protocol PublishableCollectionFetcher: CollectionFetcher {
	var statePublisher: Published<BackendFetchState<Value>>.Publisher { get }
}

public protocol PublishableSingleItemFetcher: SingleItemFetcher {
	var statePublisher: Published<BackendFetchState<Value>>.Publisher { get }
}

#warning("Move Fetcher's rails and airtable responses to BespokelyKit")

// MARK: Single Extension

public extension SingleItemFetcher {
	typealias Item = Value
	typealias AirtableItemRecords = AirtableRecords<Item>
	
	#if canImport(Alamofire)
	typealias ItemResponse = AFDataResponse<Item>
	typealias RailsItemData = RailsResponse<Item>
	typealias AFRailsItemResponse = AFDataResponse<RailsItemData>
	
	func defaultResponse(_ response: ItemResponse, animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let item): state = .success(item)
			}
		}
	}
	
	func defaultResponse(_ response: AFRailsItemResponse, animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let item): state = .success(item.data)
			}
		}
	}
	
	func defaultResponse(_ response: ItemResponse) {
		defaultResponse(response, animate: false, debug: .default)
	}
	func defaultResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (ItemResponse) -> Void {
		{ self.defaultResponse($0, animate: animate, debug: debugDepth) }
	}
	
	func defaultResponse(_ response: AFRailsItemResponse) {
		defaultResponse(response, animate: false, debug: .default)
	}
	func defaultResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsItemResponse) -> Void {
		{ self.defaultResponse($0, animate: animate, debug: debugDepth) }
	}
	#endif
	
	#if DEBUG
	@inlinable static var demoFetched: Self { demo(.success(demoData)) }
	@inlinable static func demoFetched(_ item: Value) -> Self { demo(.success(item)) }
	#endif
}

// MARK: Collection Extension

public extension CollectionFetcher {
	typealias Item = Value.Element
	typealias LossyValue = LossyArray<Item>
	typealias AirtableItemRecords = AirtableRecords<Value.Element>
	typealias RailsLossyItemData = RailsLossyResponses<Value.Element>
	typealias RailsStrictItemData = RailsStrictResponses<Value.Element>
	typealias RailsItemData = RailsResponse<Item>
	
	#if canImport(Alamofire)
	typealias ItemResponse = AFDataResponse<Item>
	typealias LossyValueResponse = AFDataResponse<LossyValue>
	
	typealias AFAirtableResponse = AFDataResponse<AirtableItemRecords>
	typealias AFRailsLossyResponse = AFDataResponse<RailsLossyItemData>
	typealias AFRailsStrictResponse = AFDataResponse<RailsStrictItemData>
	
	typealias AFRailsItemResponse = AFDataResponse<RailsItemData>
	
	func defaultResponse(_ response: LossyValueResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .success(Value(result.wrappedValue))
			}
		}
	}
	
	func defaultResponse(_ response: AFAirtableResponse) {
		if debug { print(response.debugDescription(.default)) }
		switch response.result {
		case .failure: state = .failed(response)
		case .success(let result): state = .success(Value(result.records))
		}
	}
	
	func defaultResponse(_ response: AFRailsLossyResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .success(Value(result.data))
			}
		}
	}
	
	func defaultResponse(_ response: AFRailsStrictResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .success(Value(result.data))
			}
		}
	}
	
	func defaultResponse(_ response: ItemResponse) {
		if debug { print(response.debugDescription(.default)) }
		switch response.result {
		case .failure: state = .failed(response)
		case .success(let item): state = .success(item)
		}
	}
	
	func defaultResponse(_ response: AFRailsItemResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .success(result.data)
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFAirtableResponse) {
		if debug { print(response.debugDescription(.default)) }
		switch response.result {
		case .failure: state = .failed(response)
		case .success(let result): state = .nonEmptySuccess(Value(result.records))
		}
	}
	
	func nonEmptyResponse(_ response: LossyValueResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .nonEmptySuccess(Value(result.wrappedValue))
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFRailsLossyResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .nonEmptySuccess(Value(result.data))
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFRailsStrictResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .nonEmptySuccess(Value(result.data))
			}
		}
	}
	
	func defaultResponse(_ response: LossyValueResponse) {
		defaultResponse(response, false, debug: .default)
	}
	func defaultResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (LossyValueResponse) -> Void {
		{ self.defaultResponse($0, animate, debug: debugDepth) }
	}
	
	func defaultResponse(_ response: AFRailsLossyResponse) {
		defaultResponse(response, false, debug: .default)
	}
	func defaultResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsLossyResponse) -> Void {
		{ self.defaultResponse($0, animate, debug: debugDepth) }
	}
	
	func defaultResponse(_ response: AFRailsStrictResponse) {
		defaultResponse(response, false, debug: .default)
	}
	func defaultResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsStrictResponse) -> Void {
		{ self.defaultResponse($0, animate, debug: debugDepth) }
	}
	
	func defaultResponse(_ response: AFRailsItemResponse) {
		defaultResponse(response, false, debug: .default)
	}
	func defaultResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsItemResponse) -> Void {
		{ self.defaultResponse($0, animate, debug: debugDepth) }
	}
	
	func nonEmptyResponse(_ response: LossyValueResponse) {
		nonEmptyResponse(response, false, debug: .default)
	}
	func nonEmptyResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (LossyValueResponse) -> Void {
		{ self.nonEmptyResponse($0, animate, debug: debugDepth) }
	}
	
	func nonEmptyResponse(_ response: AFRailsLossyResponse) {
		nonEmptyResponse(response, false, debug: .default)
	}
	func nonEmptyResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsLossyResponse) -> Void {
		{ self.nonEmptyResponse($0, animate, debug: debugDepth) }
	}
	
	func nonEmptyResponse(_ response: AFRailsStrictResponse) {
		nonEmptyResponse(response, false, debug: .default)
	}
	func nonEmptyResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsStrictResponse) -> Void {
		{ self.nonEmptyResponse($0, animate, debug: debugDepth) }
	}
	#endif
	
	#if DEBUG
	@inlinable static var demoFetched: Self { demo(.success(Value(demoData))) }
	@inlinable static var demoFetchedOne: Self { demo(.success(Value(demoData.prefix(1).asArray()))) }
	@inlinable static var demoFetchedNone: Self { demo(.empty) }
	@inlinable static var demoEmptyFailure: Self { demo(.emptyFailure) }
	@inlinable static func demoFetched(_ items: [Item]) -> Self { demo(.success(Value(items))) }
	@inlinable static func demoFetched(_ items: Item...) -> Self { demo(.success(Value(items))) }
	#endif
}

#if DEBUG
extension CollectionFetcher {
	public init(arrayLiteral elements: Item...) {
		self.init()
		self.state = .success(Value(elements))
	}
}
#endif

#if canImport(Alamofire)
public extension CollectionFetcher where Item: Identifiable {
	func defaultResponse(_ response: AFRailsLossyResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result):
				state = .success(Value(result.data.removingHashableDuplicates(by: \.id)))
			}
		}
	}
	
	func defaultResponse(_ response: AFRailsStrictResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result):
				state = .success(Value(result.data.removingHashableDuplicates(by: \.id)))
			}
		}
	}
	
	func defaultResponse(_ response: AFRailsLossyResponse) {
		defaultResponse(response, false, debug: .default)
	}
	func defaultResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsLossyResponse) -> Void {
		{ self.defaultResponse($0, animate, debug: debugDepth) }
	}
	
	func defaultResponse(_ response: AFRailsStrictResponse) {
		defaultResponse(response, false, debug: .default)
	}
	func defaultResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsStrictResponse) -> Void {
		{ self.defaultResponse($0, animate, debug: debugDepth) }
	}
	
	func nonEmptyResponse(_ response: AFRailsLossyResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result):
				state = .nonEmptySuccess(Value(result.data.removingHashableDuplicates(by: \.id)))
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFRailsStrictResponse, _ animate: Bool, debug debugDepth: DebugDepth) {
		if debug || debugDepth.is(not: .none, .default) { print(response.debugDescription(debugDepth)) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result):
				state = .nonEmptySuccess(Value(result.data.removingHashableDuplicates(by: \.id)))
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFRailsLossyResponse) {
		nonEmptyResponse(response, false, debug: .default)
	}
	func nonEmptyResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsLossyResponse) -> Void {
		{ self.nonEmptyResponse($0, animate, debug: debugDepth) }
	}
	
	func nonEmptyResponse(_ response: AFRailsStrictResponse) {
		nonEmptyResponse(response, false, debug: .default)
	}
	func nonEmptyResponse(animate: Bool, debug debugDepth: DebugDepth = .default) -> (AFRailsStrictResponse) -> Void {
		{ self.nonEmptyResponse($0, animate, debug: debugDepth) }
	}
}
#endif

public extension SingleItemFetcher where Item: AirtableModel {
	typealias K = Item.Fields.CodingKeys
}

public extension SingleItemFetcher where Item: RailsModel {
	typealias Key = Item.CodingKeys
}

public extension CollectionFetcher where Item: AirtableModel {
	typealias K = Item.Fields.CodingKeys
}

public extension CollectionFetcher where Item: RailsModel {
	typealias Key = Item.CodingKeys
}

// MARK: Screen w/ Fetcher

public protocol ScreenWithFetcher {
	associatedtype Fetcher: QizhKit.Fetcher
	
	var fetcher: Self.Fetcher { get }
	
	func fetchIfNeeded()
	func fetch()
}

public extension ScreenWithFetcher {
	func fetchIfNeeded() {
		if fetcher.state.isIdle {
			fetch()
		}
	}
}

// MARK: AF Headers

#if canImport(Alamofire)
public extension Optional where Wrapped == HTTPHeader {
	func mapAsHeaders() -> HTTPHeaders? {
		switch self {
		case .none: return .none
		case .some(let header): return [header]
		}
	}
}

extension HTTPHeaders {
	public static func + (lhs: HTTPHeaders, rhs: HTTPHeader) -> HTTPHeaders {
		var copy = lhs
		copy.add(rhs)
		return copy
	}
}

extension Optional where Wrapped == HTTPHeaders {
	public static func + (lhs: HTTPHeaders?, rhs: HTTPHeader) -> HTTPHeaders {
		switch lhs {
		case .some(let headers): return headers + rhs
		case .none: return HTTPHeaders(.just(rhs))
		}
	}
}

// MARK: Response Debug

extension DataResponse {
	public func debugDescription(_ debugDepth: DebugDepth) -> String {
		guard debugDepth.is(not: .none) else {
			return "[Result]: \(result.caseName)"
		}
		
		guard let request = request else {
			return """
			[Request]: None
			[Result]: \(result.caseName)
			"""
		}
		
		let printableTypes = ["json", "xml", "text", "form-urlencoded", "graphql"]
		
		// MARK: Request
		
		let requestBodyDescription: String
		if let data = request.httpBody, !data.isEmpty {
			let isPrintableType = printableTypes
				.compactMap { type in
					request.headers["Content-Type"]?
						.contains(type)
				}
				.contains(true)
			if isPrintableType, data.count <= debugDepth.maxDataCount {
				requestBodyDescription = """
				[Body]:
				    \(String(decoding: data, as: UTF8.self)
						.withLinesNSpacesTrimmed
						.offsettingNewLines())
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
			        \("\(request.headers.sorted())".offsettingNewLines(by: 8))
			"""
		}
		if requestBodyDescription.isNotEmpty {
			requestDescription += .newLine + """
			    \(requestBodyDescription.offsettingNewLines())
			"""
		}
		
		// MARK: Response
		
		let responseDescription = response.map { response in
			let responseBodyDescription: String
			if let data = data, !data.isEmpty {
				let isPrintableType = printableTypes
					.compactMap { type in
						response.headers["Content-Type"]?
							.contains(type)
					}
					.contains(true)
				if data.count <= debugDepth.maxDataCount,
				   isPrintableType {
					responseBodyDescription = """
					[Body]:
					    \(String(decoding: data, as: UTF8.self).withLinesNSpacesTrimmed.offsettingNewLines())
					"""
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
				        \("\(response.headers.sorted())".offsettingNewLines(by: 8))
				"""
			}
			if responseBodyDescription.isNotEmpty {
				if description.isNotEmpty {
					description += .newLine
				}
				description += """
					\(responseBodyDescription.offsettingNewLines())
				"""
			}
			if description.isNotEmpty {
				description = "[Response]:" + .newLine + description
			}
			return description
		} ?? (debugDepth > .minimum ? "[Response]: None" : .empty)
		
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
		
		output += .newLine + "[Result]: \(result.caseName)"
		
		return output
	}
}
#endif
