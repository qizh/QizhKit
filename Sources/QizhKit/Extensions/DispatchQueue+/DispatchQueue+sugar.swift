//
//  DispatchQueue+sugar.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 26.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public func execute(
	in ms: Int = .zero,
	withAnimation animation: Animation? = .none,
	_ work: @escaping @Sendable @MainActor () -> Void
) {
	var action: @Sendable @MainActor () -> Void
	if let animation {
		action = {
			withAnimation(animation) {
				work()
			}
		}
	} else {
		action = work
	}
	
	Task { @MainActor in
		if ms.isZero {
			action()
		} else {
			await Task.sleep(milliseconds: ms)
			action()
		}
	}

}

public func execute <T> (
	in ms: Int = .zero,
	_ work: @escaping @Sendable @MainActor (T) -> Void,
	_ argument: T
) where T: Sendable {
	if ms.isZero {
		Task { @MainActor in
			work(argument)
		}
	} else {
		Task { @MainActor in
			await Task.sleep(milliseconds: ms)
			work(argument)
		}
	}
}

public func execute <T1, T2> (
	in ms: Int = .zero,
	_ work: @escaping @Sendable @MainActor (T1, T2) -> Void,
	_ argument1: T1,
	_ argument2: T2
) where T1: Sendable,
		T2: Sendable {
	if ms.isZero {
		Task { @MainActor in
			work(argument1, argument2)
		}
	} else {
		Task { @MainActor in
			await Task.sleep(milliseconds: ms)
			work(argument1, argument2)
		}
	}
}

public func executing(
	in ms: Int = .zero,
	_ work: @escaping MainQueue.Callback
) -> () -> Void {
	if ms.isZero {
		return {
			Task { @MainActor in
				work()
			}
		}
	} else {
		return {
			Task { @MainActor in
				await Task.sleep(milliseconds: ms)
				work()
			}
		}
	}
}

@inlinable public func animating(
	_ work: @escaping @Sendable () -> Void,
	with animation: Animation?
) -> () -> Void {
	{ withAnimation(animation, work) }
}

// MARK: Assign

/// Assign a value on the Main Queue
@inlinable
public func executeAssign <T> (
	_ value: T,
	to binding: Binding<T>
) where T: Sendable {
	execute { binding.wrappedValue = value }
}

/// Will only assign a different value on the Main Queue
@inlinable
public func executeUpdate <T> (
	_ binding: Binding<T>,
	with value: T
) where T: Equatable,
		T: Sendable {
	if binding.wrappedValue != value {
		executeAssign(value, to: binding)
	}
}

// MARK: Flow

public enum ExecutionFlow: Equatable, Sendable {
	case current
	case onMainThread
	case delayed(milliseconds: Int)
	
	// MARK: Now
	
	@inlinable public func proceed(
		with callback: @escaping @Sendable () -> Void
	) {
		switch self {
		case .current: callback()
		case .onMainThread: execute(callback)
		case .delayed(let ms): execute(in: ms, callback)
		}
	}
	
	@inlinable public func proceed <T> (
		with callback: @escaping @Sendable (T) -> Void,
		_ arg: T
	) where T: Sendable {
		switch self {
		case .current: callback(arg)
		case .onMainThread: execute { callback(arg) }
		case .delayed(let ms): execute(in: ms) { callback(arg) }
		}
	}
	
	@inlinable public func proceed <T1, T2> (
		with callback: @escaping @Sendable (T1, T2) -> Void,
		_ arg1: T1,
		_ arg2: T2
	) where T1: Sendable,
			T2: Sendable {
		switch self {
		case .current: callback(arg1, arg2)
		case .onMainThread: execute { callback(arg1, arg2) }
		case .delayed(let ms): execute(in: ms) { callback(arg1, arg2) }
		}
	}
	
	// MARK: In Future
	
	@inlinable public func proceeding(
		with callback: @escaping @Sendable () -> Void
	) -> () -> Void {
		{ self.proceed(with: callback) }
	}
	
	@inlinable public func proceeding <T> (
		with callback: @escaping @Sendable (T) -> Void,
		_ arg: T
	) -> () -> Void where T: Sendable {
		{ self.proceed(with: callback, arg) }
	}
	
	@inlinable public func proceeding <T> (
		with callback: @escaping @Sendable (T) -> Void
	) -> (T) -> Void where T: Sendable {
		{ arg in self.proceed(with: callback, arg) }
	}
	
	@inlinable public func proceeding <T1, T2> (
		with callback: @escaping @Sendable (T1, T2) -> Void,
		_ arg1: T1,
		_ arg2: T2
	) -> () -> Void where T1: Sendable,
						  T2: Sendable {
		{ self.proceed(with: callback, arg1, arg2) }
	}
	
	@inlinable public func proceeding <T1, T2> (
		with callback: @escaping @Sendable (T1, T2) -> Void
	) -> (T1, T2) -> Void where T1: Sendable,
								T2: Sendable {
		{ arg1, arg2 in self.proceed(with: callback, arg1, arg2) }
	}
}

public struct MainQueue {
	public typealias Callback = @Sendable @MainActor () -> Void
	public typealias CallbackWithValue<T> = @Sendable @MainActor (T) -> Void where T: Sendable
	public typealias CallbackWithTwoValues<T1, T2> = @Sendable @MainActor (T1, T2) -> Void
		where T1: Sendable, T2: Sendable
	public typealias CallbackWithThreeValues<T1, T2, T3> = @Sendable @MainActor (T1, T2, T3) -> Void
		where T1: Sendable, T2: Sendable, T3: Sendable

	@inlinable public static func call(in milliseconds: Int, execute work: @escaping Callback) {
		Task { @MainActor in
			await Task.sleep(milliseconds: milliseconds)
			work()
		}
	}
	
	@inlinable public static func function(calling work: @escaping Callback, in milliseconds: Int) -> Callback {{
		Task { @MainActor in
			await Task.sleep(milliseconds: milliseconds)
			work()
		}
	}}
	
	@inlinable public static func execute(_ work: @escaping Callback) {
		Task { @MainActor in
			work()
		}
	}
	
	@inlinable public static func function(executing work: @escaping Callback) -> Callback {{
		Task { @MainActor in
			work()
		}
	}}
	
	@inlinable public static func function<T>(
		executing work: @escaping CallbackWithValue<T>
	) -> CallbackWithValue<T> {
		{ t in
			Task { @MainActor in
				work(t)
			}
		}
	}
	
	@inlinable public static func function<T1, T2>(
		executing work: @escaping CallbackWithTwoValues<T1, T2>
	) -> CallbackWithTwoValues<T1, T2> {
		{ t1, t2 in
			Task { @MainActor in
				work(t1, t2)
			}
		}
	}
	
	// TODO: Finish with Variadic Generics
}
