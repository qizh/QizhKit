//
//  FetchStructs.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 11.09.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine
import QizhMacroKit

// MARK: Progress

public struct FetchProgress:
	Hashable,
	Sendable,
	WithDefault,
	EasyComparable,
	CustomStringConvertible,
	ExpressibleByNilLiteral,
	ExpressibleByFloatLiteral,
	ExpressibleByStringLiteral,
	ExpressibleByIntegerLiteral
{
	public typealias Percents = Double
	
	fileprivate(set) public var state: State
	
	public init(_ state: State = .undetermined) { self.state = state.normalized }
	
	@inlinable public init(_ value: Double) { self.init(.progress(value)) }
	@inlinable public init(current: Double, total: Double) { self.init(current / total) }
	
	@inlinable public init(nilLiteral: ()) 				{ self.init(.undetermined) }
	@inlinable public init(floatLiteral value: Double) 	{ self.init(.progress(value)) }
	@inlinable public init(integerLiteral value: UInt) 	{ self.init(.progress(Double(value))) }
	@inlinable public init(stringLiteral value: String) {
		if let double = Double(value)
			 { self.init(.progress(double)) }
		else { self.init(.undetermined) }
	}
	
	@inlinable public static func finished<T: BinaryInteger>(_ current: T, of total: T) -> Self {
		.init(current: Double(current), total: Double(total))
	}
	
	@inlinable public static func finished<T: BinaryFloatingPoint>(_ current: T, of total: T) -> Self {
		.init(current: Double(current), total: Double(total))
	}
	
	public enum State: Hashable, Sendable, CaseComparable {
		case none
		case undetermined
		case progress(_ value: Percents = .zero)
		case complete
		
		public static let progress: State = .progress()
		
		public var normalized: State {
			if case .progress(let percents) = self {
				switch percents {
				case let value where value >= .one: return .complete
				case let value where value < .zero: return .none
				case let value where value == .zero: fallthrough
				case .nan: return .undetermined
				default: break
				}
			}
			return self
		}
	}
	
	public static let `default`: FetchProgress = .undetermined
	@inlinable public static var none: FetchProgress { .init(.none) }
	@inlinable public static var undetermined: FetchProgress { .init(.undetermined) }
	@inlinable public static func progress(_ value: Percents = .zero) -> FetchProgress { .init(value) }
	@inlinable public static var complete: FetchProgress { .init(.complete) }
	
	@inlinable public func `is`(_ other: State) -> Bool { state.is(other) }
	@inlinable public var isNone: Bool { state.is(.none) }
	@inlinable public var isUndetermined: Bool { state.is(.undetermined) }
	@inlinable public var isProgress: Bool { state.is(.progress) }
	@inlinable public var isComplete: Bool { state.is(.complete) }
	
	public var value: Percents {
		switch state {
		case .none: 					return .zero
		case .undetermined: 			return .nan
		case .progress(let percents): 	return  percents
		case .complete: 				return .one
		}
	}
	
	public var definedValue: Percents {
		switch state {
		case .none: 					return .zero
		case .undetermined: 			return .zero
		case .progress(let percents): 	return  percents
		case .complete: 				return .one
		}
	}
	
	public var description: String {
		switch state {
		case .none: 				return "0%"
		case .undetermined: 		return "◌"
		case .progress(let value): 	return "\((value * 100).rounded(.towardZero))%"
		case .complete: 			return "✓"
		}
	}
	
	@inlinable public var cgvalue: CGFloat { CGFloat(value) }
	@inlinable public var percents: Int { Int((value * 100).rounded(.towardZero)) }
}

extension FetchProgress: Updatable {
	@inlinable public var normalized: Self { updating(\.state).with(state.normalized) }
}

extension FetchProgress {
	@inlinable var v: Percents { definedValue }
	
	public static func + (l: Self, r: Self) -> Self { .init(l.v + r.v) }
	public static func - (l: Self, r: Self) -> Self { .init(l.v - r.v) }
	public static func * <Ti: BinaryInteger> (l: Self, r: Ti) -> Self { .init(l.v * Double(r)) }
	public static func / <Ti: BinaryInteger> (l: Self, r: Ti) -> Self { .init(l.v / Double(r)) }
	public static func * <Tf: BinaryFloatingPoint> (l: Self, r: Tf) -> Self { .init(l.v * Double(r)) }
	public static func / <Tf: BinaryFloatingPoint> (l: Self, r: Tf) -> Self { .init(l.v / Double(r)) }
//	public static func & (l: Self, r: Self) -> Self { .init((l.v + r.v).half) }
}

public extension String.StringInterpolation {
	mutating func appendInterpolation(_ value: FetchProgress) {
		appendInterpolation(value.description)
	}
}

// MARK: - Basic State

@CaseName
public enum BasicBackendFetchState: Hashable,
									Sendable,
									EasyCaseComparable
{
	case idle, inProgress, success, failure
}

extension BasicBackendFetchState {
	public init(_ progress: FetchProgress) {
		switch progress.state {
		case .none: 		self = .inProgress
		case .undetermined: self = .inProgress
		case .progress(_): 	self = .inProgress
		case .complete: 	self = .success
		}
	}
	
	@inlinable public var progress: FetchProgress {
		switch self {
		case .idle: 		.none
		case .inProgress: 	.undetermined
		case .success: 		.complete
		case .failure: 		.none
		}
	}
}

extension BasicBackendFetchState: CustomStringConvertible {
	@inlinable public var description: String {
		caseName.toSnakeCase
	}
}

// MARK: - General State

public protocol GeneralBackendFetchState: ImportanceProvider, Sendable {
	var name: String { get }
	var fetcherName: String? { get }
	
	var isInProgress: Bool { get }
	var isIdle: Bool { get }
	var isFetched: Bool { get }
	var isSuccess: Bool { get }
	var isFailure: Bool { get }
	var isCancelled: Bool { get }
	
	var error: FetchError? { get }
	var progress: FetchProgress? { get }
	var definedProgress: FetchProgress { get }
	
	var asGeneral: GeneralBackendFetchState { get }
	var asBasic: BasicBackendFetchState { get }
}

public extension GeneralBackendFetchState {
	var asGeneral: GeneralBackendFetchState { self }
}

public typealias GeneralStatePublisher = AnyPublisher<GeneralBackendFetchState, Never>

public extension GeneralBackendFetchState {
	var importance: Int {
		switch self.asBasic {
		case .idle: 		return 0
		case .inProgress: 	return 2
		case .failure: 		return 3
		case .success: 		return 1
		}
	}
}

public extension BackendFetchState {
	var asBasic: BasicBackendFetchState {
		switch self {
		case .idle: 				return .idle
		case .inProgress: 			return .inProgress
		case .fetched(.success): 	return .success
		case .fetched(.failure): 	return .failure
		}
	}
}

public protocol BackendFetchStateWithResult {
	associatedtype Value: Sendable
	var isSuccess: Bool { get }
	var value: Value? { get }
}

public protocol BackendFetchStateWithCollectionResult: BackendFetchStateWithResult where Value: Collection {
	var isEmpty: Bool { get }
	var isNotEmpty: Bool { get }
	var first: Value.Element? { get }
	var count: Int { get }
}

typealias GeneralBackendFetchStateWithResult = GeneralBackendFetchState & BackendFetchStateWithResult
extension BackendFetchState: GeneralBackendFetchStateWithResult where Value: Sendable { }

extension Result: CaseComparable { }

extension BackendFetchState: Equatable where Value: Equatable { }
extension BackendFetchState: Hashable where Value: Hashable { }
// extension BackendFetchState: Sendable where Value: Sendable { }

extension BackendFetchState: Identifiable {
	public var id: String {
		var result = "." + asBasic.caseName
		if let progress = progress {
			result += "(" + (progress.state.is(.progress) ? "\(progress.value))" : "." + progress.state.caseName + ")")
		}
		if let error = error {
			result += "(.\(error))"
		}
		if let value = value {
			result += "(" + id(of: value) + ")"
		}
		return result
	}
	
	private func id<T>(of value: T) -> String {
		"\(value)"
	}
	
	private func id<T>(of value: T) -> String where T: Identifiable {
		"\(value.id)"
	}
}

fileprivate class BackendFetcherName: @unchecked Sendable {
	// Singleton instance
	static let shared = BackendFetcherName()
	
	// Private initializer to enforce singleton usage
	private init() {}
	
	// Private mutable state
	private var fetcherNames: [String: String] = [:]
	
	private let queue = DispatchQueue(label: "com.yourapp.BackendFetcherNameQueue", attributes: .concurrent)
	
	func set<T>(name: String, for type: T.Type) {
		let key = String(describing: type)
		queue.async(flags: .barrier) {
			self.fetcherNames[key] = name
		}
	}
	
	func of<T>(_ type: T.Type) -> String? {
		let key = String(describing: type)
		return queue.sync {
			fetcherNames[key]
		}
	}
}

public extension BackendFetchState {
	// Method to set the fetcher name
	static func fetcherName(_ name: String) -> String {
		BackendFetcherName.shared.set(name: name, for: Value.self)
		return name
	}
	
	// Computed property to get the fetcher name
	var fetcherName: String? {
		BackendFetcherName.shared.of(Value.self)
	}
}

// MARK: - State

public enum BackendFetchState<Value: Sendable>: Sendable {
	case idle
	case inProgress(_ value: FetchProgress = .default)
	case fetched(_ result: Result<Value, FetchError>)
	
	// MARK: > Fail
	
	@inlinable
	public static func failed(with fetchError: FetchError) -> Self {
		.fetched(.failure(fetchError))
	}
	
	@inlinable
	public static func failed(with error: Error) -> Self {
		if let fetchError = error as? FetchError {
			return .failed(with: fetchError)
		} else {
			return .failed(with: .providerError(error.localizedDescription, error))
		}
	}
	
	@inlinable
	public static func failed(with error: Error, description: String) -> Self {
		.failed(with: .providerError(description, error))
	}
	@inlinable
	public static func contentError(_ message: String) -> Self {
		.failed(with: .contentError(message))
	}
	@inlinable
	public static func failed(_ message: String) -> Self {
		.failed(with: .error(message))
	}
	@inlinable
	public static func verboseError(_ title: String, _ description: String) -> Self {
		.failed(with: .verboseError(title, description))
	}
	@inlinable
	public static func cancelled() -> Self {
		.failed(with: .cancelled)
	}
	@inlinable
	public static func apiError(_ code: Int, _ message: String) -> Self {
		.failed(with: .api(code, message))
	}

	// MARK: > Success
	
	@inlinable
	public static func success(_ data: Value) -> Self {
		.fetched(.success(data))
	}
	
	// MARK: > In Progress
	
	@inlinable public static var inProgress: Self {
		.inProgress()
	}
	@inlinable
	public static func progress(_ value: Double) -> Self {
		.inProgress(.init(value))
	}
	@inlinable
	public static func progress(received current: Double, of total: Double) -> Self {
		.inProgress(.init(current: current, total: total))
	}
	@inlinable
	public static func progress(received current: Int, of total: Int) -> Self {
		.inProgress(.init(current: Double(current), total: Double(total)))
	}
	
	@inlinable public static var progressUndetermined: Self { .inProgress(.undetermined) }
	@inlinable public static var progressZero: Self 		{ .inProgress(.none) }
	@inlinable public static var progressThird: Self 		{ .progress(1/3) }
	@inlinable public static var progressHalf: Self 		{ .progress(1/2) }
	@inlinable public static var progressTwoThirds: Self 	{ .progress(2/3) }
	@inlinable public static var progressComplete: Self 	{ .inProgress(.complete) }
	@inlinable public static var progress0: Self 			{ .inProgress(.none) }
	@inlinable public static var progress30: Self 			{ .progress(1/3) }
	@inlinable public static var progress50: Self 			{ .progress(1/2) }
	@inlinable public static var progress60: Self 			{ .progress(2/3) }
	@inlinable public static var progress100: Self 			{ .inProgress(.complete) }

	public var name: String {
		switch self {
		case .fetched(let result): return result.caseName
		default: return caseName
		}
	}
	
	@inlinable public var isInProgress: Bool { self.is(.inProgress) }
	@inlinable public var isIdle: Bool { self.is(.idle) }
	@inlinable public var isCancelled: Bool { error?.isCancelled == true }
	
	@inlinable public var isFetched: Bool {
		switch self {
		case .fetched(_): return true
		default: return false
		}
	}
	
	@inlinable public var isSuccess: Bool {
		switch self {
		case .fetched(.success): return true
		default: return false
		}
	}
	
	@inlinable public var isFailure: Bool {
		switch self {
		case .fetched(.failure): return true
		default: return false
		}
	}
	
	/// `true` when failed or idle
	@inlinable public var isReadyToStart: Bool {
		switch self {
		case .fetched(.failure): return true
		case .idle: 			 return true
		case .fetched(.success): return false
		case .inProgress: 		 return false
		}
	}
	
	/// `true` when succees or idle
	@inlinable public var haveSucceedOrNotStarted: Bool {
		switch self {
		case .fetched(.failure): return false
		case .idle: 			 return true
		case .fetched(.success): return true
		case .inProgress: 		 return false
		}
	}
	
	@inlinable public var hasValue: Bool { value.isSet }
	
	// MARK: > Values
	
	public var error: FetchError? {
		if case let .fetched(.failure(error)) = self
			 { return error }
		else { return nil }
	}
	
	public var value: Value? {
		if case let .fetched(.success(value)) = self
			 { return value }
		else { return nil }
	}
	
	public var progress: FetchProgress? {
		if case let .inProgress(progress) = self
			 { return progress }
		else { return nil }
	}
	
	public var definedProgress: FetchProgress {
		switch self  {
		case .idle: 					return .undetermined
		case .inProgress(let progress): return  progress
		case .fetched(.failure): 		return .none
		case .fetched(.success): 		return .complete
		}
	}
	
	/// Less common
	
	public var contentError: FetchError? { error?.isContentError == true ? error : nil }
}

public extension BackendFetchState where Value: Collection, Value: EmptyTestable {
	@inlinable static func nonEmptySuccess(_ items: Value) -> Self {
		items.nonEmpty.map(Self.success) ?? .emptyFailure
	}
}

extension BackendFetchState where Value: Collection {
	public static var emptyFailure: Self { .fetched(.failure(.emptyContentError)) }
	public var emptyContentError: FetchError? { error?.isEmptyContentError == true ? error : nil }
}

public extension BackendFetchState where Value: InitializableCollection {
	@inlinable static var success: Self { success(Value()) }
	@inlinable static var empty: Self { success(Value()) }
}

public extension BackendFetchState where Value: InitializableWithSequenceCollection {
	@inlinable static func success(_ item: Value.Element) -> Self { .success(Value([item])) }
}

extension BackendFetchState: BackendFetchStateWithCollectionResult
	where Value: Collection
{
	@inlinable public var first: Value.Element? { value?.first }
	@inlinable public var count: Int { value?.count ?? .zero }
	/// - `has value` -> `value.isEmpty`
	/// - `nil value` -> `false`
	@inlinable public var isEmpty: Bool { value?.isEmpty ?? false }
	/// - `has value` -> `value.isNotEmpty`
	/// - `nil value` -> `false`
	@inlinable public var isNotEmpty: Bool { value?.isEmpty.toggled ?? false }
	@inlinable public var didFetchNone: Bool { value?.isEmpty == true }
}

extension BackendFetchState: CaseNameProvidable { }
extension BackendFetchState: EasySelfComparable {
	public func `is`(_ other: Self) -> Bool {
		switch (self, other) {
		case (             .idle, .idle             ): return true
		case (       .inProgress, .inProgress       ): return true
		case (.fetched(.success), .fetched(.success)): return true
		case (.fetched(.failure), .fetched(.failure)): return true
		default: return false
		}
	}
}

extension BackendFetchState: CustomStringConvertible {
	public var description: String {
		switch self {
		case .idle: return ".idle"
		case .inProgress(let progress): return ".inProgress(\(progress.cgvalue, f: 1))"
		case .fetched(.success(_)): return ".success"
		case .fetched(.failure(_)): return ".failure"
		}
	}
}

// MARK: > Map Views

public extension GeneralBackendFetchState {
	
	// MARK: >> Idle
	
	@inlinable func mapIdle<I: View>(@ViewBuilder to view: () -> I) -> I? { isIdle ? view() : nil }
	@inlinable func mapIdle<I: View>(             to view: I      ) -> I? { isIdle ? view   : nil }
//	@inlinable func whenIdle<I: View>(@ViewBuilder show view: () -> I) -> I? { isIdle ? view() : nil }
	@inlinable @MainActor var idleDefaultView: Pixel? { isIdle ? Pixel() : nil }
//	@inlinable var idleDefaultView: Pixel? { isIdle.then(use: Pixel()) }

	// MARK: >> Progress
	
	@inlinable func mapProgress<P: View>(@ViewBuilder to view: (FetchProgress) -> P, success: Bool = false) -> P? {
		progress.map(view: view)
			?? (success && isSuccess).then(view: view(.complete))
	}
	@inlinable func whenInProgress<P: View>(@ViewBuilder show view: () -> P, success: Bool = false) -> P? {
		isInProgress.then(produce: view)
			?? (success && isSuccess).then(view: view)
	}
	
	#if canImport(UIKit)
	@inlinable @MainActor var inProgressDefaultView: ProgressView? { inProgressDefaultView() }
	@MainActor func inProgressDefaultView(
		size: ProgressView.Size = .visual,
		success: Bool = false,
		color mode: ProgressView.ColorMode = .multi,
		show states: ProgressView.StatesSet = .all
	) -> ProgressView? {
		progress
			.map(view: ProgressView.sized(size, color: mode))
			?? (success && isSuccess)
				.then(view: ProgressView(state: self, size: size, show: states, color: mode))
	}

	// MARK: >> Idle + Progress
	
	@inlinable @MainActor var defaultIdleAndProgress: _ConditionalContent<Pixel, ProgressView>? {
		defaultIdleAndProgress()
	}
	
	@MainActor func defaultIdleAndProgress(
		size: ProgressView.Size = .visual,
		color: ProgressView.ColorMode = .multi,
		success: Bool = false,
		show visibleStates: ProgressView.StatesSet = .all
	) -> _ConditionalContent<Pixel, ProgressView>? {
		if isIdle {
			ViewBuilder.buildEither(first: Pixel())
		} else if isInProgress || (isSuccess && success) {
			ViewBuilder.buildEither(second:
				ProgressView(state: self, size: size, show: visibleStates, color: color)
			)
		} else {
			nil
		}
	}
	#endif
}

// MARK: > Most important State

public protocol ImportanceProvider {
	var importance: Int { get }
}

public extension Collection where Element: ImportanceProvider {
	@inlinable func sortedByImportance() -> [Element] { sorted(by: \.importance) }
	@inlinable var mostImportant: Element? { lazy.sortedByImportance().last }
}

// MARK: > Hash

extension FetchError: CaseNameProvidable, Equatable, Hashable {
	public func hash(into hasher: inout Hasher) {
		hasher.combine(caseName)
		hasher.combine(localizedDescription)
	}
}

// MARK: - Fetch Error

public protocol FetchResponse {
	var request: URLRequest? { get }
	var response: HTTPURLResponse? { get }
	var data: Data? { get }
	var metrics: URLSessionTaskMetrics? { get }
	var serializationDuration: TimeInterval { get }
	var valueDescription: String? { get }
	var underlying: Error? { get }
}

@CaseName @IsCase
public enum FetchError: Error, EasyCaseComparable, Sendable {
	case doubleErrors(Error, Error)
	case error(String)
	case providerError(String, Error)
	case multipleProvidersError([String])
	case afError(String, _ response: FetchResponse & Sendable)
	case deleteError(String)
	case contentError(String)
	case verboseError(_ title: String, _ description: String? = .none)
	case api(_ code: Int, _ message: String)
	case appLogicError(
			statement: String = "We deeply apologize for our developer's mistake, please be so kind to report this issue so we can justify the punishment",
			reason: String,
			func: String? = #function,
			file: String? = #file,
			line: Int? = #line
		 )
	case sign(SignFailureReason)
	case preconditionValidation(PreconditionValidationReason)
	case priceMismatch(_ message: String)
	case passwordResetTokenExpired
	
	case cancelled
	case paymentFailed
	case notFound
	case unauthorized
	case unauthorizedCallPrevented
	case accessForbidden
	case emptyContentError
	case notImplemented
	case unknown
	
	public static func multipleErrors(_ errors: [any Error]) -> Self {
		var errors: [FetchError] = errors
			.enumerated()
			.map { offset, error in
				if let fetchError = error as? FetchError {
					fetchError
				} else {
					.providerError(offset.s, error)
				}
			}
		
		while errors.count > 2 {
			errors = errors
				.chunked(into: 2)
				.compactMap { chunk in
					if chunk.isPair {
						.doubleErrors(chunk[0], chunk[1])
					} else {
						chunk.first
					}
				}
		}
		
		return errors.first ?? .unknown
	}
	
	@inlinable public static func multipleErrors(_ errors: (any Error)...) -> Self {
		multipleErrors(errors)
	}
	
	public enum PreconditionValidationReason: Equatable, Sendable {
		case illegalCharacters(_ value: String)
		case missingInput(_ input: String, details: String? = .none)
		case missingAuthentication
	}
	
	public enum SignFailureReason: Equatable, Sendable,
								   EasyCaseComparable, CaseNameProvidable {
		case userExists(_ loginMethod: ExistingUserLogin)
		case userNotFound(_ loginMethod: ExistingUserLogin)
		case inactiveUserExists
		case usernameTaken
		case wrongCredentials
		case wrongEmail
		case wrongPassword
		case tokenExpired
		// case tokenInvalid
		case airtableUserNotFound
		case createUserFirst
		case wrongCode
		
		public enum ExistingUserLogin: Equatable, Sendable,
									   EasyCaseComparable, CaseNameProvidable {
			case unknown
			case google
			case apple
			case both
		}
	}
	
	/// Creates an `.appLogicError`
	/// - Parameters:
	///   - expected: A model name expected by `FetchersHarbor`
	///   - fetching: A model name fetching
	///   - function: Do not provide any value
	///   - file: Do not provide any value
	///   - line: Do not provide any value
	/// - Returns: `FetchError` instance
	public static func harborError(
		expecting expected: String,
		fetching fetchable: String,
		function: String = #function,
		file: String = #file,
		line: Int = #line
	) -> FetchError {
		.appLogicError(
			reason: "\(expected) not found when fetching \(fetchable) using harbor",
			func: function,
			file: file,
			line: line
		)
	}
	
	@inlinable
	public static func providerError(_ error: Error) -> Self {
		.providerError(.empty, error)
	}
	
	public static func == (lhs: FetchError, rhs: FetchError) -> Bool {
		switch (lhs, rhs) {
		case (                    .cancelled,                     .cancelled): 	return true
		case (                     .notFound,                      .notFound): 	return true
		case (                 .unauthorized,                  .unauthorized): 	return true
		case (    .unauthorizedCallPrevented,     .unauthorizedCallPrevented): 	return true
		case (            .emptyContentError,             .emptyContentError): 	return true
		case (                      .unknown,                       .unknown): 	return true
		
		case (                 .error(let l),                  .error(let r)): 	return l == r
		case (           .deleteError(let l),            .deleteError(let r)): 	return l == r
		case (          .contentError(let l),           .contentError(let r)): 	return l == r
		case (.multipleProvidersError(let l), .multipleProvidersError(let r)): 	return l == r
		case (.appLogicError(_, let l, _, _, _), .appLogicError(_, let r, _, _, _)): return l == r
		case (                  .sign(let l),                   .sign(let r)): 	return l == r
		case (.preconditionValidation(let l), .preconditionValidation(let r)): 	return l == r
		
		case ( .verboseError(let l1, let l2),  .verboseError(let r1, let r2)):
			return l1 == r1 && l2 == r2
		case (     .api(let l1, let l2),      .api(let r1, let r2)):
			return l1 == r1 && l2 == r2
		case (      .afError(let l1, let l2),       .afError(let r1, let r2)):
			return l1 == r1 && l2.data == r2.data
		case (.providerError(let l1, let l2), .providerError(let r1, let r2)):
			return l1 == r1 && l2.localizedDescription == r2.localizedDescription
		default: return false
		}
	}
	
	/*
	public var errorDescription: String? {
		switch self {
		case .error(let message): 					return message
		case .deleteError(let message): 			return message
		case .contentError(let message): 			return message
		case .providerError(let message, let error):
			return message.nonEmpty ?? error.localizedDescription
		case .multipleProvidersError(let messages): return messages.joined(separator: .comaspace)
		case .afError(let message, _): 				return message
		case .appLogicError(let statement, _, _, _, _):
			return statement
		case .verboseError(let title, let description):
			var result = title
			if let description = description {
				result += " (\(description))"
			}
			return result
		
		case let .api(code, message):
			return "API Error #\(code)\(map: message.nonEmpty, ": $0")"
		
		case .emptyContentError:
			return "No items here"
		case .cancelled:
			return "Someone have canceled the action. It was you, right?"
		case .paymentFailed:
			return "We were not able to proceed with your payment."
		case .notFound:
			return "Not found"
		case .unauthorized:
			return "You were not active for a while. Please login and try again."
		case .unauthorizedCallPrevented:
			return "You are not authorised to perform this action. Please login and try again."
		case .accessForbidden:
			return "You don't have permission to view this content."
		case .unknown:
			return "Unknown error"
		case .sign(.userExists(.unknown)):
			return "A user with this email already exists. Try to log in."
		case .sign(.userExists(.google)):
			return "You've signed up before, try logging in with Google"
		case .sign(.userExists(.both)): fallthrough
		case .sign(.userExists(.apple)):
			return "You've signed up before, try logging in with Apple"
		case .sign(.inactiveUserExists):
			return "This email was used already, please sign up"
		case .sign(.usernameTaken):
			return "The username is taken, try again with another one"
		case .sign(.wrongCredentials):
			return "Wrong password or no such user"
		case .sign(.wrongEmail):
			return "Wrong email"
		case .sign(.wrongPassword):
			return "Wrong password"
		case .sign(.tokenExpired):
			return "Your session is expired, please login"
		case .sign(.airtableUserNotFound):
			return "Database record mismatch, please report"
		case .sign(.createUserFirst):
			return "All values should be provided"
		case .sign(.wrongCode):
			return "Code doesn't match"
		case .preconditionValidation(.illegalCharacters(_)):
			return "Input contains illegal characters"
		case .priceMismatch(_):
			return "The price doesn't match"
		case .passwordResetTokenExpired:
			return "Password reset URL have expired"
		case .notImplemented:
			return "This functionality is not implemented"
		}
	}
	*/
	
	public var haveSomethingImportantToSay: Bool {
		switch self {
		case .error(_): 					return false
		case .providerError(_, let error as FetchError):
			return error.haveSomethingImportantToSay
		case .providerError(_, _): 			return false
		case .multipleProvidersError(_): 	return false
		case .afError(_, _): 				return false
		case .deleteError(_): 				return false
		case .contentError(_): 				return false
		case .verboseError(_, _): 			return true
		case .api(_, _): 					return false
		case .appLogicError(_, _, _, _, _): return false
		case .sign(.createUserFirst): 		return false
		case .sign(.wrongCode): 			return false
		case .sign(.userNotFound(.apple)): 	return true
		case .sign(_): 						return true
		case .cancelled: 					return false
		case .paymentFailed: 				return true
		case .notFound: 					return true
		case .unauthorized: 				return true
		case .unauthorizedCallPrevented: 	return true
		case .accessForbidden: 				return true
		case .emptyContentError: 			return true
		case .unknown: 						return false
		case .preconditionValidation(_): 	return false
		case .priceMismatch(_): 			return true
		case .passwordResetTokenExpired: 	return true
		case .notImplemented: 				return true
		case let .doubleErrors(e1 as FetchError, e2 as FetchError):
			return e1.haveSomethingImportantToSay || e2.haveSomethingImportantToSay
		case .doubleErrors(let e as FetchError, _),
			 .doubleErrors(_, let e as FetchError):
			return e.haveSomethingImportantToSay
		case .doubleErrors(_, _): 			return false
		}
	}
		
	@inlinable public var verboseErrorDetails: (title: String, description: String?)? {
		switch self {
		case .verboseError(let t, let d): return (title: t, description: d)
		default: return nil
		}
	}
	
	@inlinable public var providerError: Error? {
		switch self {
		case .providerError(_, let error): return error
		default: return nil
		}
	}
	
	@inlinable public var response: FetchResponse? {
		switch self {
		case .afError(_, let response): return response
		default: return nil
		}
	}
}

extension FetchError: Identifiable {
	public var id: String {
		QizhKit.caseName(of: self, .identifiable)
	}
}

public extension Collection where Element == FetchError {
	func combined() -> FetchError {
		.multipleProvidersError(map(\.localizedDescription))
	}
}
