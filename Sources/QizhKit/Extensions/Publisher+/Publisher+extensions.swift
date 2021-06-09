//
//  Publisher+extensions.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 17.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine

// MARK: Optional

public extension Publisher {
	@inlinable func compactMap<T>() -> Publishers.CompactMap<Self, T> where Output == T? {
		let transform: (Output) -> Output = \.self
		return compactMap(transform)
//		compactMap(\.asOptional)
	}
	
	@inlinable func compactMap<Cast>(as type: Cast.Type) -> Publishers.CompactMap<Self, Cast> {
		compactMap({ $0 as? Cast })
	}

	@inlinable func compactMap<T, Cast>(_ transform: @escaping (Output) -> T, as type: Cast.Type) -> Publishers.CompactMap<Self, Cast> {
		compactMap({ transform($0) as? Cast })
	}
	
	@inlinable func undefinedOnly<T>() -> Publishers.Filter<Self> where Output == T? {
		filter(\.isNotSet)
	}
	
	
	@inlinable func filter(_ isIncluded: @escaping (Output) -> Bool?) -> Publishers.Filter<Self> {
		filter({ isIncluded($0) == true })
	}
	@inlinable func filter(not isNotIncluded: @escaping (Output) -> Bool?) -> Publishers.Filter<Self> {
		filter({ isNotIncluded($0) != true })
	}
}

public extension Publisher {
	@inlinable func map<In, Out>(_ transform: @escaping (In) -> Out) -> Publishers.Map<Self, Out?> where Output == In? {
		map({ $0.map(transform) })
	}
	
	@inlinable func flatMap<In, Out>(_ transform: @escaping (In) -> Out?) -> Publishers.Map<Self, Out?> where Output == In? {
		map({ $0.flatMap(transform) })
	}
	
	@inlinable func compactMap<Output1, Output2>() -> Publishers.CompactMap<Self, (Output1, Output2)> where Output == (Output1?, Output2?) {
		compactMap(unwrap)
	}
	@inlinable func compactMap<Output1, Output2, Output3>() -> Publishers.CompactMap<Self, (Output1, Output2, Output3)> where Output == (Output1?, Output2?, Output3?) {
		compactMap(unwrap)
	}
	@inlinable func compactMap<Output1, Output2, Output3, Output4>() -> Publishers.CompactMap<Self, (Output1, Output2, Output3, Output4)> where Output == (Output1?, Output2?, Output3?, Output4?) {
		compactMap(unwrap)
	}
	
	/*
	@available(*, deprecated, renamed: "compactMap", message: "Use compactMap() instead")
	@inlinable func definedOnly<Output1, Output2>() -> Publishers.CompactMap<Self, (Output1, Output2)> where Output == (Output1?, Output2?) {
		compactMap(unwrap)
	}
	@available(*, deprecated, renamed: "compactMap", message: "Use compactMap() instead")
	@inlinable func definedOnly<Output1, Output2, Output3>() -> Publishers.CompactMap<Self, (Output1, Output2, Output3)> where Output == (Output1?, Output2?, Output3?) {
		compactMap(unwrap)
	}
	@available(*, deprecated, renamed: "compactMap", message: "Use compactMap() instead")
	@inlinable func definedOnly<Output1, Output2, Output3, Output4>() -> Publishers.CompactMap<Self, (Output1, Output2, Output3, Output4)> where Output == (Output1?, Output2?, Output3?, Output4?) {
		compactMap(unwrap)
	}
	*/
	
	@inlinable func undefinedOnly<Output1, Output2>() -> Publishers.Filter<Publishers.Map<Self, (Output1, Output2)?>> where Output == (Output1?, Output2?) {
		map(unwrap).filter(\.isNotSet)
	}
	@inlinable func undefinedOnly<Output1, Output2, Output3>() -> Publishers.Filter<Publishers.Map<Self, (Output1, Output2, Output3)?>> where Output == (Output1?, Output2?, Output3?) {
		map(unwrap).filter(\.isNotSet)
	}
	@inlinable func undefinedOnly<Output1, Output2, Output3, Output4>() -> Publishers.Filter<Publishers.Map<Self, (Output1, Output2, Output3, Output4)?>> where Output == (Output1?, Output2?, Output3?, Output4?) {
		map(unwrap).filter(\.isNotSet)
	}
	
	@inlinable func isDefined<Wrapped>() -> Publishers.MapKeyPath<Self, Bool> where Output == Wrapped? {
		map(\.isSet)
	}
}

@inlinable public func optionals<A, B>(_ a: A?, _ b: B?) -> (A, B)? { unwrap((a, b)) }
@inlinable public func unwrap<A, B>(_ value: (a: A?, b: B?)) -> (A, B)? {
    return
		value.a.flatMap { a -> (A, B)? in
			value.b.flatMap { b -> (A, B)? in
				(a, b)
			}
		}
}

@inlinable public func optionals<A, B, C>(_ a: A?, _ b: B?, _ c: C?) -> (A, B, C)? { unwrap((a, b, c)) }
@inlinable public func unwrap<A, B, C>(_ value: (a: A?, b: B?, c: C?)) -> (A, B, C)? {
    return
		value.a.flatMap { a -> (A, B, C)? in
			value.b.flatMap { b -> (A, B, C)? in
				value.c.flatMap { c -> (A, B, C)? in
					(a, b, c)
				}
			}
		}
}

public func unwrap<A, B, C, D>(_ value: (a: A?, b: B?, c: C?, d: D?)) -> (A, B, C, D)? {
    return
		value.a.flatMap { a -> (A, B, C, D)? in
			value.b.flatMap { b -> (A, B, C, D)? in
				value.c.flatMap { c -> (A, B, C, D)? in
					value.d.flatMap { d -> (A, B, C, D)? in
						(a, b, c, d)
					}
				}
			}
		}
}

// MARK: AND, OR

public extension Publisher {
	@inlinable func and() -> Publishers.Map<Self, Bool>
		where Output == (Bool, Bool)
	{
		map { $0 && $1 }
	}
	@inlinable func and() -> Publishers.Map<Self, Bool>
		where Output == (Bool, Bool, Bool)
	{
		map { $0 && $1 && $2 }
	}
	@inlinable func and() -> Publishers.Map<Self, Bool>
		where Output == (Bool, Bool, Bool, Bool)
	{
		map { $0 && $1 && $2 && $3 }
	}
	@inlinable func and() -> Publishers.Map<Self, Bool>
		where Output == (Bool, Bool, Bool, Bool, Bool)
	{
		map { $0 && $1 && $2 && $3 && $4 }
	}

	@inlinable func or() -> Publishers.Map<Self, Bool>
		where Output == (Bool, Bool)
	{
		map { $0 || $1 }
	}
	@inlinable func or() -> Publishers.Map<Self, Bool>
		where Output == (Bool, Bool, Bool)
	{
		map { $0 || $1 || $2 }
	}
	@inlinable func or() -> Publishers.Map<Self, Bool>
		where Output == (Bool, Bool, Bool, Bool)
	{
		map { $0 || $1 || $2 || $3 }
	}
	@inlinable func or() -> Publishers.Map<Self, Bool>
		where Output == (Bool, Bool, Bool, Bool, Bool)
	{
		map { $0 || $1 || $2 || $3 || $4 }
	}
}

// MARK: Equal

public extension Publisher {
	@inlinable
	func areEqual <T> () -> Publishers.Map<Self, Bool>
		where Output == (T, T), T: Equatable
	{
		map { $0 == $1 }
	}
	
	@inlinable
	func areNotEqual <T> () -> Publishers.Map<Self, Bool>
	where Output == (T, T), T: Equatable
	{
		map { $0 != $1 }
	}
}

// MARK: Clip

public extension Publisher where Output: Comparable {
	func clip(from: Output? = nil, to: Output? = nil) -> Publishers.Map<Self, Self.Output> {
		map({ $0.clipped(from: from ?? $0, to: to ?? $0) })
	}
	
	func clip(from: Self? = nil, to: Self? = nil)
		-> Publishers.Map<Publishers.CombineLatest3<Self, Self, Self>, Self.Output>
	{
		Publishers.CombineLatest3(self, from ?? self, to ?? self)
			.map({ $0.clipped(from: $1, to: $2) })
	}
	
	func clip<C>(in collection: C) -> Publishers.Map<Self, Self.Output> where C: BidirectionalCollection, C.Element == Output {
		map({
			$0.clipped(from: collection.first ?? $0, to: collection.last ?? $0)
		})
	}
	
	func clip<P>(in collection: P)
		-> Publishers.Map<Publishers.CombineLatest<Self, P>, Self.Output>
		where
		P: Publisher,
		P.Output: BidirectionalCollection,
		P.Output.Element == Output,
		P.Failure == Failure
	{
		combineLatest(collection)
			.map({ $0.clipped(from: $1.first ?? $0, to: $1.last ?? $0) })
	}
}

public extension Publisher where Output: Strideable {
	func clip(_ range: ClosedRange<Output>) -> Publishers.Map<Self, Self.Output> {
		map({ $0.clipped(range) })
	}
}

// MARK: Collection and Sequence

public extension Publisher where Output: Collection {
	@inlinable func elementsMap <T> (
		_ transform: @escaping (Output.Element) -> T
	) -> Publishers.Map<Self, [T]> {
		map({ $0.map(transform) })
	}
	
	@inlinable func elementsCompactMap <T> (
		_ transform: @escaping (Output.Element) -> T?,
		nonEmpty: Bool = false
	) -> Publishers.CompactMap<Self, [T]> {
		compactMap(
			nonEmpty
			? { $0.compactMap(transform).nonEmpty }
			: { $0.compactMap(transform) }
		)
	}
	
	@inlinable
	func optionalFirstElement() -> Publishers.Map<Self, Self.Output.Element?> {
		map(\.first)
	}
	
	@inlinable
	func mandatoryFirstElement() -> Publishers.CompactMap<Self, Self.Output.Element> {
		compactMap(\.first)
	}
}

public extension Publisher where Output: BidirectionalCollection {
	@inlinable
	func optionalLastElement() -> Publishers.Map<Self, Self.Output.Element?> {
		map(\.last)
	}
	
	@inlinable
	func mandatoryLastElement() -> Publishers.CompactMap<Self, Self.Output.Element> {
		compactMap(\.last)
	}
}

public extension Publisher where Output: Collection & EmptyTestable {
	@inlinable func isEmpty() -> Publishers.MapKeyPath<Self, Bool> {
		map(\.isEmpty)
	}
	
	@inlinable func isNotEmpty() -> Publishers.MapKeyPath<Self, Bool> {
		map(\.isNotEmpty)
	}
	
	@inlinable func nonEmpty() -> Publishers.Filter<Self> {
		filter(\.isNotEmpty)
	}
	
	@inlinable func empty() -> Publishers.Filter<Self> {
		filter(\.isEmpty)
	}
}

// MARK: Remove Duplicates

extension Publisher {
	@inlinable
	public func removeDuplicates <T> (
		by transform: @escaping (Output) -> T
	) -> Publishers.RemoveDuplicates<Self>
		where T: Equatable
	{
		removeDuplicates { prev, current in
			transform(prev) == transform(current)
		}
	}
}

// MARK: Filter

public extension Publisher {
	@inlinable func filter<T>(equals value: T) -> Publishers.Filter<Self> where T == Output, T: Equatable {
		filter { $0 == value }
	}
	
	@inlinable func filter<T>(is value: T) -> Publishers.Filter<Self> where T == Output, T: CaseComparable {
		filter { $0.is(value) }
	}
	
	@inlinable func equals<T>(to value: @autoclosure @escaping () -> T) -> Publishers.Map<Self, Bool> where T == Output, T: Equatable {
		map { $0 == value() }
	}
	
	@inlinable func `is`<T>(_ value: T) -> Publishers.Map<Self, Bool> where T == Output, T: CaseComparable {
		map { $0.is(value) }
	}
	
	@inlinable func `is`(_ compare: @escaping (Output, Output) -> Bool, _ value: Output) -> Publishers.Map<Self, Bool> {
		map({ compare($0, value) })
	}
	
	@inlinable func `is`<Value>(_ transform: @escaping (Output) -> Value, _ compare: @escaping (Value, Value) -> Bool, _ value: Value) -> Publishers.Map<Self, Bool> {
		map({ compare(transform($0), value) })
	}
	
	@inlinable func set<Value>(_ calculate: @escaping (Value, Value) -> Value, _ value: Value) -> Publishers.Map<Self, Value> where Value == Output {
		map({ calculate($0, value) })
	}
	
	@inlinable func set<Value>(_ value: Value, _ calculate: @escaping (Value, Value) -> Value) -> Publishers.Map<Self, Value> where Value == Output {
		map({ calculate(value, $0) })
	}
	
	@inlinable func filter<T>(notEquals value: T) -> Publishers.Filter<Self> where T == Output, T: Equatable {
		filter { $0 != value }
	}
	
	@inlinable func filter<T>(isNot value: T) -> Publishers.Filter<Self> where T == Output, T: CaseComparable {
		filter { $0.isNot(value) }
	}
	
	@inlinable func notEquals<T>(to value: @autoclosure @escaping () -> T) -> Publishers.Map<Self, Bool> where T == Output, T: Equatable {
		map { $0 != value() }
	}
	
	@inlinable func isNot<T>(_ value: T) -> Publishers.Map<Self, Bool> where T == Output, T: CaseComparable {
		map { $0.isNot(value) }
	}
	
	
	@inlinable func filter<T>(_ keyPath: KeyPath<Output, T>, equals value: T) -> Publishers.Filter<Self> where T: Equatable {
		filter { $0[keyPath: keyPath] == value }
	}
	
	@inlinable func filter<T>(_ keyPath: KeyPath<Output, T>, notEquals value: T) -> Publishers.Filter<Self> where T: Equatable {
		filter { $0[keyPath: keyPath] != value }
	}
	
	@inlinable func filter<T>(_ keyPath: KeyPath<Output, T>, is value: T) -> Publishers.Filter<Self> where T: CaseComparable {
		filter { $0[keyPath: keyPath].is(value) }
	}
	
	@inlinable func filter<T>(_ keyPath: KeyPath<Output, T>, isNot value: T) -> Publishers.Filter<Self> where T: CaseComparable {
		filter { $0[keyPath: keyPath].isNot(value) }
	}
	
	
//	@inlinable func filter(_ keyPath: KeyPath<Output, Bool>) -> Publishers.Filter<Self> {
//		filter { $0[keyPath: keyPath] }
//	}
	
	@inlinable func filter(not keyPath: KeyPath<Output, Bool>) -> Publishers.Filter<Self> {
		filter { !$0[keyPath: keyPath] }
	}
}

// MARK: Filter EasyComparable

public extension Publisher {
	@inlinable func filter<T>(is values: T...) -> Publishers.Filter<Self> where Output: EasyComparable, Output.Other == T {
		filter { $0.in(values) }
	}
	
	@inlinable func filter<T>(in values: [T]) -> Publishers.Filter<Self> where Output: EasyComparable, Output.Other == T {
		filter { $0.in(values) }
	}
	
	@inlinable func `in`<T>(_ values: T...) -> Publishers.Map<Self, Bool> where Output: EasyComparable, Output.Other == T {
		map { $0.in(values) }
	}
	
	@inlinable func `in`<T>(_ values: [T]) -> Publishers.Map<Self, Bool> where Output: EasyComparable, Output.Other == T {
		map { $0.in(values) }
	}
	
	@inlinable func `is`<T>(not values: T...) -> Publishers.Map<Self, Bool> where Output: EasyComparable, Output.Other == T {
		map { $0.is(not: values) }
	}
	
	@inlinable func `is`<T>(not values: [T]) -> Publishers.Map<Self, Bool> where Output: EasyComparable, Output.Other == T {
		map { $0.is(not: values) }
	}
	
	@inlinable func filter<T>(not values: T...) -> Publishers.Filter<Self> where Output: EasyComparable, Output.Other == T {
		filter { $0.is(not: values) }
	}
	
	@inlinable func filter<T>(not values: [T]) -> Publishers.Filter<Self> where Output: EasyComparable, Output.Other == T {
		filter { $0.is(not: values) }
	}
}

// MARK: Assign

public extension Publisher {
	@inlinable func assign<T, Root>(_ value: T, to keyPath: ReferenceWritableKeyPath<Root, T>, on object: Root) -> AnyCancellable where Failure == Never {
		self
			.map { _ in value }
			.assign(to: keyPath, on: object)
	}
	
	@inlinable func assignToggled<Root>(to keyPath: ReferenceWritableKeyPath<Root, Bool>, on object: Root) -> AnyCancellable where Failure == Never, Output == Bool {
		self
			.map(\.toggled)
			.assign(to: keyPath, on: object)
	}
	
	/*
	@available(*, deprecated, renamed: "assignToggled", message: "Use 'assignToggled' instead")
	@inlinable func assignOpposite<Root>(to keyPath: ReferenceWritableKeyPath<Root, Bool>, on object: Root) -> AnyCancellable where Failure == Never, Output == Bool {
		self
			.map(\.toggled)
			.assign(to: keyPath, on: object)
	}
	*/
	
	@inlinable func assign<Root>(on object: Root, to keyPaths: ReferenceWritableKeyPath<Root, Output> ...) -> AnyCancellable where Failure == Never {
		sink {
			for keyPath in keyPaths {
				object[keyPath: keyPath] = $0
			}
		}
	}
	
//	@inlinable func assign<Root, T>(_ value: T, on object: Root) -> AnyCancellable where Output == ReferenceWritableKeyPath<Root, T>, Failure == Never {
//		sink { object[keyPath: $0] = value }
//	}
	
}

public extension Publisher where Failure == Never {
	@inlinable func assign <Root> (
		to keyPath: ReferenceWritableKeyPath<Root, Output>,
		on object: Root,
		with animation: Animation
	) -> AnyCancellable {
		sink { value in
			withAnimation(animation) {
				object[keyPath: keyPath] = value
			}
		}
	}
}

// MARK: Sink

public extension Publisher where Failure == Never {
	@inlinable func call(_ action: @escaping () -> Void) -> AnyCancellable {
		sink(ignoreValue: action)
	}
	
	@inlinable func sink(ignoreValue action: @escaping () -> Void) -> AnyCancellable {
		sink(receiveValue: { _ in action() })
	}
}

// MARK: Update

public extension Publisher {
	func updating<T>(_ keyPath: WritableKeyPath<Output, T>, with value: T) -> Publishers.Map<Self, Output> {
		map { var copy = $0
			  copy[keyPath: keyPath] = value
			  return copy }
	}
	
	func updating(with update: @escaping (inout Output) -> Void) -> Publishers.Map<Self, Output> {
		map { var copy = $0
			  update(&copy)
			  return copy }
	}
}

// MARK: Bool

public extension Publisher where Output == Bool {
	@inlinable func trueOnly() -> Publishers.Filter<Self> {
		filter { $0 }
	}
	
	@inlinable func falseOnly() -> Publishers.Filter<Self> {
		filter(\.toggled)
	}
	
	@inlinable func toggle() -> Publishers.MapKeyPath<Self, Bool> {
		map(\.toggled)
	}
	@inlinable func not() -> Publishers.MapKeyPath<Self, Bool> {
		map(\.toggled)
	}
}

public extension Publisher {
	@inlinable func map(not keyPath: KeyPath<Output, Bool>) -> Publishers.MapKeyPath<Self, Bool> {
		map(keyPath.appending(path: \.toggled))
	}
}

// MARK: Collection

//extension Publisher {
//	@inlinable func compactMap<T>(_ keyPath: KeyPath<Output, T?>)
//		-> Publishers.CompactMap<Publishers.MapKeyPath<Self, T?>, T>
//	{
//		self
//			.map(keyPath)
//			.definedOnly()
//	}
//}

// MARK: Ignore input

public extension Publisher where Failure == Never {
	@inlinable func ignore() -> AnyCancellable {
		sink { _ in }
	}
}

public extension Publisher {
	@inlinable func set<T>(_ value: T) -> Publishers.Map<Self, T> {
		map { _ in value }
	}
}

// MARK: String

public extension Publisher where Output == String {
	@inlinable func trimming(_ set: CharacterSet) -> Publishers.Map<Self, String> {
		map { $0.trimmingCharacters(in: set) }
	}
	@inlinable func trimmingWhitespaces() -> Publishers.Map<Self, String> {
		trimming(.whitespaces)
	}
	@inlinable func trimmingWhitespacesAndNewLines() -> Publishers.Map<Self, String> {
		trimming(.whitespacesAndNewlines)
	}
	
	@inlinable func handleUserInput(interval: Int = 200)
		-> Publishers.RemoveDuplicates<Publishers.Map<Publishers.Debounce<Self, RunLoop>, String>>
	{
		/// Mayde I should use .throttle(for: .milliseconds(300), scheduler: RunLoop.main, latest: true)
		self.debounce(for: interval)
			.trimmingWhitespacesAndNewLines()
			.removeDuplicates()
	}
	
	@inlinable func handlePasswordInput(interval: Int = 200)
		-> Publishers.RemoveDuplicates<Publishers.Debounce<Self, RunLoop>>
	{
		self.debounce(for: interval)
			.removeDuplicates()
	}
}

public extension Publisher {
	@inlinable func known<Known>() -> Publishers.CompactMap<Self, Known> where Output == ExtraCase<Known> {
		compactMap(\.known)
	}
	@inlinable func unknown<Known>() -> Publishers.MapKeyPath<Self, Bool> where Output == ExtraCase<Known> {
		map(not: \.known.isSet)
	}
}

// MARK: Concurency

public extension Publisher {
	@inlinable func receiveOnMainThread() -> Publishers.ReceiveOn<Self, RunLoop> {
		receive(on: RunLoop.main)
	}
	
	@inlinable func delay(for milliseconds: Int) -> Publishers.Delay<Self, RunLoop> {
		delay(for: .milliseconds(milliseconds), scheduler: RunLoop.main)
	}
	
	@inlinable func debounce(for milliseconds: Int) -> Publishers.Debounce<Self, RunLoop> {
		debounce(for: .milliseconds(milliseconds), scheduler: RunLoop.main)
	}
}

// MARK: Shorter Calls

public extension Publisher {
	@inlinable var any: AnyPublisher<Output, Failure> { eraseToAnyPublisher() }
}

// MARK: Debug

public extension Publisher {
	@inlinable func breakpoint(_ receiveOutput: @escaping (Output) -> Bool) -> Publishers.Breakpoint<Self> {
		breakpoint(receiveOutput: receiveOutput)
	}
	
	@inlinable func breakpoint() -> Publishers.Breakpoint<Self> {
		breakpoint(receiveOutput: { _ in true })
	}
	
	@inlinable func printOutput(prefix: String = .empty, sufix: String = .empty) -> Publishers.Map<Self, Output> {
		map {
			Swift.print(prefix, String(describing: $0) + sufix)
			return $0
		}
	}
}

public extension Publisher where Failure == Never {
	func printOutput(prefix: String = .empty, sufix: String = .empty, in set: inout Set<AnyCancellable>) -> Self {
		self.sink {
			Swift.print(prefix, String(describing: $0) + sufix)
		}
		.store(in: &set)
		return self
	}
}

/*
// MARK: Deprecated

public extension Publisher {
	@available(*, deprecated, renamed: "compactMap", message: "Use compactMap() instead")
	@inlinable func definedOnly<T>() -> Publishers.CompactMap<Self, T> where Output == T? {
		compactMap()
	}
}

public extension Publisher where Output == Bool {
	@available(*, deprecated, renamed: "toggle", message: "Use 'toggle()' instead")
	@inlinable func opposite() -> Publishers.MapKeyPath<Self, Bool> {
		map(\.toggled)
	}
}
*/

// MARK: Value Change

public extension Publisher {
	typealias ValueChangePublisher = Publishers.Scan<Self, PublishedValueChange<Output>>
	typealias PreviousValuePublisher = Publishers.Map<ValueChangePublisher, Output>
	
	@inlinable func asValueChange(first: Output) -> ValueChangePublisher {
		scan(
			PublishedValueChange(filling: first)
		) { stack, value in
			stack.push(value)
		}
	}
	
	@inlinable func previousValue(first: Output) -> PreviousValuePublisher {
		self
			.asValueChange(first: first)
			.map(\.previous)
	}
	
	@inlinable func asPreviousValue<T>() -> Publishers.MapKeyPath<Self, T> where Output == PublishedValueChange<T> {
		map(\.previous)
	}
	
	@inlinable func asCurrentValue<T>() -> Publishers.MapKeyPath<Self, T> where Output == PublishedValueChange<T> {
		map(\.current)
	}
}

public extension Publisher {
	@inlinable func filter<T>(oneEquals value: T) -> Publishers.Filter<Self> where Output == PublishedValueChange<T>, T: Equatable {
		filter { value == $0.previous || value == $0.current }
	}
	
	@inlinable func filter<T>(noneEquals value: T) -> Publishers.Filter<Self> where Output == PublishedValueChange<T>, T: Equatable {
		filter { value != $0.previous && value != $0.current }
	}
	
	@inlinable func filter<T>(oneIs value: T) -> Publishers.Filter<Self> where Output == PublishedValueChange<T>, T: CaseComparable {
		filter { value.isOne(of: $0.previous, $0.current) }
	}
	
	@inlinable func filter<T>(noneIs value: T) -> Publishers.Filter<Self> where Output == PublishedValueChange<T>, T: CaseComparable {
		filter { value.isNotOne(of: $0.previous, $0.current) }
	}
	
	@inlinable func filter<T>(oneIs value: T) -> Publishers.Filter<Self> where Output == PublishedValueChange<T>, T: EasyComparable, T.Other == T {
		filter { value.in($0.previous, $0.current) }
	}
	
	@inlinable func filter<T>(noneIs value: T) -> Publishers.Filter<Self> where Output == PublishedValueChange<T>, T: EasyComparable, T.Other == T {
		filter { value.is(not: $0.previous, $0.current) }
	}
}

public extension Publisher where Output: WithDefault {
	@inlinable func asValueChange() -> ValueChangePublisher { asValueChange(first: .default) }
	@inlinable func previousValue() -> PreviousValuePublisher { previousValue(first: .default) }
}
public extension Publisher where Output == Bool {
	@inlinable func asValueChange() -> ValueChangePublisher { asValueChange(first: false) }
	@inlinable func previousValue() -> PreviousValuePublisher { previousValue(first: false) }
}
public extension Publisher where Output == String {
	@inlinable func asValueChange() -> ValueChangePublisher { asValueChange(first: "") }
	@inlinable func previousValue() -> PreviousValuePublisher { previousValue(first: "") }
}

public struct PublishedValueChange<Element> {
	public let previous: Element
	public let current: Element
	
	public init(previous: Element, current: Element) {
		self.previous = previous
		self.current = current
	}
	
	public init(_ previous: Element, _ current: Element) {
		self.previous = previous
		self.current = current
	}
	
	public init<T>(_ collection: T) where T: Collection, T.Element == Element {
		precondition(collection.count == 2, "Collections of 2 elements only are allowed")
		self.previous = collection[collection.startIndex]
		self.current = collection[collection.endIndex]
	}
	
	public init(filling value: Element) {
		self.previous = value
		self.current = value
	}
	
	public func push(_ value: Element) -> PublishedValueChange<Element> {
		.init(current, value)
	}
}

extension PublishedValueChange: Equatable where Element: Equatable { }

public extension PublishedValueChange where Element: Equatable {
	var haveNoChange: Bool { previous == current }
	var haveChanged: Bool { previous != current }
}

extension PublishedValueChange: CustomStringConvertible {
	public var description: String {
		"\(previous) > \(current)"
	}
}

public extension PublishedValueChange where Element: CaseNameProvidable {
	var description: String {
		".\(previous.caseName) > .\(current.caseName)"
	}
}

public extension PublishedValueChange where Element == Bool {
	var description: String {
		"\(previous ? 1 : 0)>\(current ? 1 : 0)"
	}
}
