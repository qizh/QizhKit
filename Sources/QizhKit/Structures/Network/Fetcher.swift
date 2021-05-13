//
//  Fetcher.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 11.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Alamofire

// MARK: Fetcher

public protocol Fetcher: ObservableObject {
	associatedtype Value: Codable, Equatable
	var state: BackendFetchState<Value> { get set }
	var debug: Bool { get set }
	init()
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

// MARK: Single Extension

public extension SingleItemFetcher {
	typealias Item = Value
	typealias ItemResponse = AFDataResponse<Item>
	
	typealias RailsItemData = RailsResponse<Item>
	typealias AFRailsItemResponse = AFDataResponse<RailsItemData>
	typealias AirtableItemRecords = AirtableRecords<Item>
	
	func defaultResponse(_ response: ItemResponse) {
		if debug { debugPrint(response) }
		switch response.result {
		case .failure: state = .failed(response)
		case .success(let item): state = .success(item)
		}
	}
	
	func defaultResponse(_ response: AFRailsItemResponse) {
		if debug { debugPrint(response) }
		switch response.result {
		case .failure: state = .failed(response)
		case .success(let item): state = .success(item.data)
		}
	}
	
	#if DEBUG
	@inlinable static var demoFetched: Self { demo(.success(demoData)) }
	@inlinable static func demoFetched(_ item: Value) -> Self { demo(.success(item)) }
	#endif
}

// MARK: Collection Extension

public extension CollectionFetcher {
	typealias Item = Value.Element
	typealias ItemResponse = AFDataResponse<Item>
	typealias LossyValue = LossyArray<Item>
	typealias LossyValueResponse = AFDataResponse<LossyValue>
	
	typealias AirtableItemRecords = AirtableRecords<Value.Element>
	typealias AFAirtableResponse = AFDataResponse<AirtableItemRecords>
	
	typealias RailsLossyItemData = RailsLossyResponses<Value.Element>
	typealias RailsStrictItemData = RailsStrictResponses<Value.Element>
	typealias AFRailsLossyResponse = AFDataResponse<RailsLossyItemData>
	typealias AFRailsStrictResponse = AFDataResponse<RailsStrictItemData>
	
	typealias RailsItemData = RailsResponse<Item>
	typealias AFRailsItemResponse = AFDataResponse<RailsItemData>
	
	func defaultResponse(_ response: LossyValueResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .success(Value(result.wrappedValue))
			}
		}
	}
	
	func defaultResponse(_ response: AFAirtableResponse) {
		if debug { debugPrint(response) }
		switch response.result {
		case .failure: state = .failed(response)
		case .success(let result): state = .success(Value(result.records))
		}
	}
	
	func defaultResponse(_ response: AFRailsLossyResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .success(Value(result.data))
			}
		}
	}
	
	func defaultResponse(_ response: AFRailsStrictResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .success(Value(result.data))
			}
		}
	}
	
	func defaultResponse(_ response: ItemResponse) {
		if debug { debugPrint(response) }
		switch response.result {
		case .failure: state = .failed(response)
		case .success(let item): state = .success(item)
		}
	}
	
	func defaultResponse(_ response: AFRailsItemResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .success(result.data)
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFAirtableResponse) {
		if debug { debugPrint(response) }
		switch response.result {
		case .failure: state = .failed(response)
		case .success(let result): state = .nonEmptySuccess(Value(result.records))
		}
	}
	
	func nonEmptyResponse(_ response: LossyValueResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .nonEmptySuccess(Value(result.wrappedValue))
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFRailsLossyResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .nonEmptySuccess(Value(result.data))
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFRailsStrictResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result): state = .nonEmptySuccess(Value(result.data))
			}
		}
	}
	
	func defaultResponse(_ response: LossyValueResponse) {
		defaultResponse(response, false)
	}
	func defaultResponse(animate: Bool) -> (LossyValueResponse) -> Void {
		{ self.defaultResponse($0, animate) }
	}
	
	func defaultResponse(_ response: AFRailsLossyResponse) {
		defaultResponse(response, false)
	}
	func defaultResponse(animate: Bool) -> (AFRailsLossyResponse) -> Void {
		{ self.defaultResponse($0, animate) }
	}
	
	func defaultResponse(_ response: AFRailsStrictResponse) {
		defaultResponse(response, false)
	}
	func defaultResponse(animate: Bool) -> (AFRailsStrictResponse) -> Void {
		{ self.defaultResponse($0, animate) }
	}
	
	func defaultResponse(_ response: AFRailsItemResponse) {
		defaultResponse(response, false)
	}
	func defaultResponse(animate: Bool) -> (AFRailsItemResponse) -> Void {
		{ self.defaultResponse($0, animate) }
	}
	
	func nonEmptyResponse(_ response: LossyValueResponse) {
		nonEmptyResponse(response, false)
	}
	func nonEmptyResponse(animate: Bool) -> (LossyValueResponse) -> Void {
		{ self.nonEmptyResponse($0, animate) }
	}
	
	func nonEmptyResponse(_ response: AFRailsLossyResponse) {
		nonEmptyResponse(response, false)
	}
	func nonEmptyResponse(animate: Bool) -> (AFRailsLossyResponse) -> Void {
		{ self.nonEmptyResponse($0, animate) }
	}
	
	func nonEmptyResponse(_ response: AFRailsStrictResponse) {
		nonEmptyResponse(response, false)
	}
	func nonEmptyResponse(animate: Bool) -> (AFRailsStrictResponse) -> Void {
		{ self.nonEmptyResponse($0, animate) }
	}
	
	#if DEBUG
	@inlinable static var demoFetched: Self { demo(.success(Value(demoData))) }
	@inlinable static var demoFetchedOne: Self { demo(.success(Value(demoData.prefix(1).asArray()))) }
	@inlinable static var demoFetchedNone: Self { demo(.empty) }
	@inlinable static var demoEmptyFailure: Self { demo(.emptyFailure) }
	@inlinable static func demoFetched(_ items: [Item]) -> Self { demo(.success(Value(items))) }
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

public extension CollectionFetcher where Item: Identifiable {
	func defaultResponse(_ response: AFRailsLossyResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result):
				state = .success(Value(result.data.removingHashableDuplicates(by: \.id)))
			}
		}
	}
	
	func defaultResponse(_ response: AFRailsStrictResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result):
				state = .success(Value(result.data.removingHashableDuplicates(by: \.id)))
			}
		}
	}
	
	func defaultResponse(_ response: AFRailsLossyResponse) {
		defaultResponse(response, false)
	}
	func defaultResponse(animate: Bool) -> (AFRailsLossyResponse) -> Void {
		{ self.defaultResponse($0, animate) }
	}
	
	func defaultResponse(_ response: AFRailsStrictResponse) {
		defaultResponse(response, false)
	}
	func defaultResponse(animate: Bool) -> (AFRailsStrictResponse) -> Void {
		{ self.defaultResponse($0, animate) }
	}
	
	func nonEmptyResponse(_ response: AFRailsLossyResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result):
				state = .nonEmptySuccess(Value(result.data.removingHashableDuplicates(by: \.id)))
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFRailsStrictResponse, _ animate: Bool) {
		if debug { debugPrint(response) }
		withAnimation(animate ? .spring() : .none) {
			switch response.result {
			case .failure: state = .failed(response)
			case .success(let result):
				state = .nonEmptySuccess(Value(result.data.removingHashableDuplicates(by: \.id)))
			}
		}
	}
	
	func nonEmptyResponse(_ response: AFRailsLossyResponse) {
		nonEmptyResponse(response, false)
	}
	func nonEmptyResponse(animate: Bool) -> (AFRailsLossyResponse) -> Void {
		{ self.nonEmptyResponse($0, animate) }
	}
	
	func nonEmptyResponse(_ response: AFRailsStrictResponse) {
		nonEmptyResponse(response, false)
	}
	func nonEmptyResponse(animate: Bool) -> (AFRailsStrictResponse) -> Void {
		{ self.nonEmptyResponse($0, animate) }
	}
}

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
