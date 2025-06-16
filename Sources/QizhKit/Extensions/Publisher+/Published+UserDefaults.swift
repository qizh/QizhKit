//
//  Published+UserDefaults.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 14.01.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation
import Combine
import os.log

// MARK: Key

extension Published {
	@_disfavoredOverload
	public init(
		wrappedValue defaultValue: Value,
		key: String,
		store: UserDefaults,
	) {
		self.init(initialValue: store.object(forKey: key) as? Value ?? defaultValue)
		
		projectedValue
			.sink { value in
				if let optional = value as? OptionalConvertible,
				   optional.isNotSet {
					store.removeObject(forKey: key)
				} else {
					store.set(value, forKey: key)
				}
			}
			.store()
	}
	
	
	/// - Parameters:
	///   - defaultValue: Optional value
	///   - key: ``UserDefaults`` key
	///   - store: ``UserDefaults``
	public init<Wrapped>(
		wrappedValue defaultValue: Value = .none,
		key: String,
		store: UserDefaults,
		// cancellables: inout Set<AnyCancellable>
	) where Value == Optional<Wrapped> {
		if let object = store.object(forKey: key),
		   let typedObject = object as? Wrapped {
			self.init(initialValue: typedObject)
		} else {
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				switch value {
				case .none: 			 store.removeObject(forKey: key)
				case .some(let wrapped): store.set(wrapped, forKey: key)
				}
			}
			.store()
	}
}

// MARK: Raw Representable Key

fileprivate let rawRepresentableLogger = Logger(subsystem: "Published", category: "RawRepresentable in UserDefaults")

extension Published
	where Value: RawRepresentable,
		  Value.RawValue == String
{
	public init(
		wrappedValue defaultValue: Value,
		representableKey key: String,
		store: UserDefaults,
	) {
		let current = store.string(forKey: key) ?? .empty
		let value = Value(rawValue: current) ?? defaultValue
		/*
		rawRepresentableLogger.debug("""
			Loging initial value
			┣ for key: \(key)
			┣ in store: \(store)
			┣ or default: \(defaultValue.rawValue)
			┣ store value: \(store.string(forKey: key))
			┗━→ value: \(value.rawValue)
			""")
		*/
		
		self.init(initialValue: value)
		
		projectedValue
			.sink { value in
				store.set(value.rawValue, forKey: key)
			}
			.store()
	}
}

extension Published
	where Value: RawRepresentable,
		  Value.RawValue == Int
{
	public init(
		wrappedValue defaultValue: Value,
		representableKey key: String,
		store: UserDefaults,
	) {
		let current = store.integer(forKey: key)
		self.init(initialValue: Value(rawValue: current) ?? defaultValue)
		
		projectedValue
			.sink { value in
				store.set(value.rawValue, forKey: key)
			}
			.store()
	}
}

// MARK: Codable

fileprivate let codableLogger = Logger(subsystem: "Published", category: "Codable in UserDefaults")

extension Published where Value: Codable {
	public init(
		wrappedValue defaultValue: Value,
		codableKey key: String,
		store: UserDefaults,
		decoder: JSONDecoder = .init(),
		encoder: JSONEncoder = .init()
	) {
		do {
			let current: Value = try store.model(forKey: key, decoder: decoder)
			self.init(initialValue: current)
		} catch {
			codableLogger.warning("Can't decode \(Value.self) from UserDefaults for `\(key)` key.\nInitializing with default value.\nError: \(error)")
			self.init(initialValue: defaultValue)
		}
		
		projectedValue
			.sink { value in
				do {
					try store.saveModel(value, forKey: key, encoder: encoder)
				} catch {
					codableLogger.error("Can't encode \(Value.self) to save in UserDefaults for `\(key)` key.\nError: \(error)")
				}
			}
			.store()
	}
}

// MARK: UserDefaults + Model

extension UserDefaults {
	public func model<Model: Decodable>(
		forKey key: String,
		decoder: JSONDecoder = .init()
	) throws -> Model {
		if let data = data(forKey: key) {
			try decoder.decode(Model.self, from: data)
		} else {
			throw DecodingError.dataCorrupted(DecodingError.Context(codingPath: [], debugDescription: "No data found for key \(key)"))
		}
	}
	
	public func saveModel<Model: Encodable>(
		_ model: Model,
		forKey key: String,
		encoder: JSONEncoder = .init()
	) throws {
		let data = try encoder.encode(model)
		set(data, forKey: key)
	}
}

// MARK: - Thread Safe Cancellables


/*
// MARK: Attempt 4

@propertyWrapper
public struct ThreadSafeWithLock<Value> {
	private var value: Value
	private let lock: NSLocking
	public var locksOnRead: Bool = false
	
	public init(
		wrappedValue: Value,
		_ lock: NSLocking = NSLock(),
		locksOnRead: Bool = false
	) {
		self.value = wrappedValue
		self.lock = lock
		self.locksOnRead = locksOnRead
	}
	
	public var wrappedValue: Value {
		get {
			if locksOnRead {
				lock.execute { value }
			} else {
				value
			}
		}
		set {
			lock.store(newValue, in: &value)
		}
	}
}

extension NSLocking {
	/// Atomically stores new value in object
	@inlinable
	public func store<T>(_ value: T, in object: inout T) {
		mutate(&object, with: { $0 = value })
	}
	
	/// Atomically mutates object with closure
	@inlinable
	public func mutate<T: AnyObject>(_ object: T, with closure: (T) -> Void) {
		execute { closure(object) }
	}
	
	/// Atomically mutates object with closure
	@inlinable
	public func mutate<T>(_ object: inout T, with closure: (inout T) -> Void) {
		execute { closure(&object) }
	}
	
	/// Atomically mutates object with closure
	@inlinable
	public func set<T: AnyObject, Value>(
		_ object: T,
		_ keyPath: ReferenceWritableKeyPath<T, Value>,
		_ value: Value
	) {
		execute { object[keyPath: keyPath] = value }
	}
	
	/// Atomically mutates object with closure
	@inlinable
	public func set<T, Value>(_ object: inout T, _ keyPath: WritableKeyPath<T, Value>, _ value: Value)
	{
		execute { object[keyPath: keyPath] = value }
	}
	
	/// Atomically executes a block of code
	@discardableResult
	@inlinable
	public func execute<T>(code closure: () -> T) -> T {
		lock()
		defer { unlock() }
		return closure()
	}
}
*/

/*
// MARK: Attempt 3

/// A thread-safe store for cancellables which addresses usability pain points
/// with stock Combine apis.
///
/// ## Thread-safe storage of cancellables
///
///     let cancelBag = CancelBag()
///     cancellable.store(in: cancelBag)
///     cancelBag.remove(cancellable)
///
/// ## Memory consumption
///
/// Use case: keep a cancellable alive until the cancelBag is drained, but
/// remove them from memory once the subscription completes or is cancelled.
///
///     // Releases memory when subscription completes or is cancelled.
///     publisher.sink(
///         in: cancelBag,
///         receiveCompletion: ...
///         receiveValue: ...)
///
///     // Manual cancellation is still possible
///     let cancellable = publisher.sink(
///         in: cancelBag,
///         receiveCompletion: ...
///         receiveValue: ...)
///     cancellable.cancel()
///
/// ## Important
///
/// CancelBag cancels its cancellables when it is deinitialized.
final class CancelBag {
	@MainActor public static let shared: CancelBag = .init()
	
	var isEmpty: Bool { synchronized { cancellables.isEmpty } }
	private var lock = NSRecursiveLock() // Allow reentrancy
	private var cancellables: [AnyCancellable] = []
	private var isCancelling = false
	
	deinit {
		cancel()
	}
	
	func remove(_ cancellable: AnyCancellable) {
		synchronized {
			if let index = cancellables.firstIndex(where: { $0 === cancellable }) {
				cancellables.remove(at: index)
			}
		}
	}
	
	fileprivate func store<T: Cancellable>(_ cancellable: T) {
		synchronized {
			if let any = cancellable as? AnyCancellable {
				// Don't lose cancellable identity, so that we can remove it.
				cancellables.append(any)
			} else {
				cancellable.store(in: &cancellables)
			}
		}
	}
	
	private func synchronized<T>(_ execute: () throws -> T) rethrows -> T {
		lock.lock()
		defer { lock.unlock() }
		return try execute()
	}
}

extension CancelBag: Cancellable {
	func cancel() {
		synchronized {
			// Avoid exclusive access violation: each cancellable may trigger a
			// call to remove(_:), and mutate self.cancellables
			let cancellables = self.cancellables
			for cancellable in cancellables {
				cancellable.cancel()
			}
			// OK, they are all cancelled now
			self.cancellables = []
		}
	}
}

extension Cancellable {
	func store(in bag: CancelBag) {
		bag.store(self)
	}
}

extension Publisher {
	/// Attaches a subscriber with closure-based behavior.
	///
	/// This method creates the subscriber and immediately requests an unlimited
	/// number of values.
	///
	/// The returned cancellable is added to cancelBag, and removed when
	/// publisher completes.
	///
	/// - parameter cancelBag: A CancelBag instance.
	/// - parameter receiveComplete: The closure to execute on completion.
	/// - parameter receiveValue: The closure to execute on receipt of a value.
	/// - returns: An AnyCancellable instance.
	@discardableResult
	func sink(
		in cancelBag: CancelBag,
		receiveCompletion: @escaping (Subscribers.Completion<Failure>) -> Void,
		receiveValue: @escaping (Output) -> Void)
		-> AnyCancellable
	{
		var cancellable: AnyCancellable?
		// Prevents a retain cycle when cancellable retains itself
		var unmanagedCancellable: Unmanaged<AnyCancellable>?
		
		cancellable = self
			.handleEvents(
				receiveCancel: { [weak cancelBag] in
					// Postpone cleanup in case subscription finishes
					// before cancellable is set.
					if let unmanagedCancellable = unmanagedCancellable {
						cancelBag?.remove(unmanagedCancellable.takeUnretainedValue())
						unmanagedCancellable.release()
					} else {
						DispatchQueue.main.async {
							if let unmanagedCancellable = unmanagedCancellable {
								cancelBag?.remove(unmanagedCancellable.takeUnretainedValue())
								unmanagedCancellable.release()
							}
						}
					}
			})
			.sink(
				receiveCompletion: { [weak cancelBag] completion in
					receiveCompletion(completion)
					// Postpone cleanup in case subscription finishes
					// before cancellable is set.
					if let unmanagedCancellable = unmanagedCancellable {
						cancelBag?.remove(unmanagedCancellable.takeUnretainedValue())
						unmanagedCancellable.release()
					} else {
						DispatchQueue.main.async {
							if let unmanagedCancellable = unmanagedCancellable {
								cancelBag?.remove(unmanagedCancellable.takeUnretainedValue())
								unmanagedCancellable.release()
							}
						}
					}
				},
				receiveValue: receiveValue)
		
		unmanagedCancellable = Unmanaged.passRetained(cancellable!)
		cancellable!.store(in: cancelBag)
		return cancellable!
	}
}

extension Publisher where Failure == Never {
	/// Attaches a subscriber with closure-based behavior.
	///
	/// This method creates the subscriber and immediately requests an unlimited
	/// number of values.
	///
	/// The returned cancellable is added to cancelBag, and removed when
	/// publisher completes.
	///
	/// - parameter cancelBag: A CancelBag instance.
	/// - parameter receiveValue: The closure to execute on receipt of a value.
	/// - returns: An AnyCancellable instance.
	@discardableResult
	func sink(
		in cancelBag: CancelBag,
		receiveValue: @escaping (Output) -> Void)
		-> AnyCancellable
	{
		sink(in: cancelBag, receiveCompletion: { _ in }, receiveValue: receiveValue)
	}
}
*/

/*
// MARK: Attempt 2

/// 1. The actor that really owns the AnyCancellable.
class CancellableBox {
	let id: UUID
	private var underlying: AnyCancellable?

	/// Designated init: no parameters, so no Sendable requirement.
	init() {
		self.id = UUID()
		self.underlying = nil
	}

	/// Delegating convenience init: can legally take a non-Sendable parameter.
	convenience init(cancellable: AnyCancellable) {
		self.init()
		self.underlying = cancellable
	}

	func cancel() {
		underlying?.cancel()
		underlying = nil
	}
}

/// 2. A truly Sendable, value‐type wrapper around that actor.
struct SendableAnyCancellable: Cancellable, Sendable, Hashable {
	let box: CancellableBox
	let id: UUID

	init(_ cancellable: AnyCancellable) {
		let b = CancellableBox(cancellable: cancellable)
		self.box = b
		self.id  = b.id
	}

	func cancel() {
		Task { await box.cancel() }
	}

	static func ==(lhs: SendableAnyCancellable, rhs: SendableAnyCancellable) -> Bool {
		lhs.id == rhs.id
	}
	func hash(into hasher: inout Hasher) {
		hasher.combine(id)
	}
}

/// 3. Your shared store actor.
actor CancellableStore {
	static let shared = CancellableStore()
	private var set = Set<SendableAnyCancellable>()

	func add(_ c: SendableAnyCancellable) {
		set.insert(c)
	}

	func cancelAll() {
		for c in set { c.cancel() }
		set.removeAll()
	}
}

/// 4. Convenience on AnyCancellable so you never have to think about it:
extension AnyCancellable {
	func store(in store: CancellableStore = .shared) {
		// build the Sendable wrapper *synchronously*
		let sendable = SendableAnyCancellable(self)
		// then hand it off via a simple actor hop
		Task { await store.add(sendable) }
	}
}
*/

/*
// MARK: Attempt 1
 
public actor CancellableStore {
	/// Shared instance if you want a global bucket.
	public static let shared = CancellableStore()

	public var set = Set<AnyCancellable>()

	/// Add a token.
	public func add(_ c: AnyCancellable) {
		set.insert(c)
	}

	/// Cancel-and-clear all tokens.
	public func cancelAll() {
		for c in set { c.cancel() }
		set.removeAll()
	}
}

extension AnyCancellable: @retroactive @unchecked Sendable {
	/// Store into an actor-backed store.
	func store(in store: CancellableStore = .shared) {
		// fire-and-forget the add call
		Task { await store.add(self) }
	}
}
*/

// MARK: - Even Older Attempts


/*
// MARK: Cancellable Store

final actor CancellableStore {
	public static let shared = CancellableStore()
	
	private var cancellables = Set<AnyCancellable>()
	
	init() {}
	
	func store(_ cancellable: AnyCancellable) {
		cancellables.insert(cancellable)
	}
	
	func cancelAll() {
		cancellables.removeAll()
	}
}

// MARK: Cancellable + store

extension AnyCancellable {
	func storeInActor(_ actor: CancellableStore) async {
		await actor.store(self)
	}
	
	func storeInSharedActor() {
		Task {
			await CancellableStore.shared.store(self)
		}
	}
}
*/

// @MainActor private var mainActorCncellables = Set<AnyCancellable>()

