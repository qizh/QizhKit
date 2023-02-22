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
	_ work: @escaping () -> Void
) {
	var action: () -> Void
	if let animation = animation {
		action = {
			withAnimation(animation, work)
		}
	} else {
		action = work
	}
	
	if ms.isZero {
		DispatchQueue.main.async(execute: action)
	} else {
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ms), execute: action)
	}
}

public func execute <T> (
	in ms: Int = .zero,
	_ work: @escaping (T) -> Void,
	_ argument: T
) {
	if ms.isZero {
		DispatchQueue.main.async {
			work(argument)
		}
	} else {
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ms)) {
			work(argument)
		}
	}
}

public func execute <T1, T2> (
	in ms: Int = .zero,
	_ work: @escaping (T1, T2) -> Void,
	_ argument1: T1,
	_ argument2: T2
) {
	if ms.isZero {
		DispatchQueue.main.async {
			work(argument1, argument2)
		}
	} else {
		DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ms)) {
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
			DispatchQueue.main.async(execute: work)
		}
	} else {
		return {
			DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(ms), execute: work)
		}
	}
}

@inlinable public func animating(
	_ work: @escaping MainQueue.Callback,
	with animation: Animation?
) -> () -> Void {
	{ withAnimation(animation, work) }
}

// MARK: Assign

/// Assign a value on the Main Queue
@inlinable
public func executeAssign <T> (_ value: T, to binding: Binding<T>) {
	execute { binding.wrappedValue = value }
}

/// Will only assign a different value on the Main Queue
@inlinable
public func executeUpdate <T: Equatable> (_ binding: Binding<T>, with value: T) {
	if binding.wrappedValue != value {
		executeAssign(value, to: binding)
	}
}

// MARK: Flow

public enum ExecutionFlow {
	case current
	case onMainThread
	case delayed(milliseconds: Int)
	
	// MARK: Now
	
	@inlinable public func proceed(
		with callback: @escaping () -> Void
	) {
		switch self {
		case .current: callback()
		case .onMainThread: execute(callback)
		case .delayed(let ms): execute(in: ms, callback)
		}
	}
	
	@inlinable public func proceed <T> (
		with callback: @escaping (T) -> Void,
		_ arg: T
	) {
		switch self {
		case .current: callback(arg)
		case .onMainThread: execute { callback(arg) }
		case .delayed(let ms): execute(in: ms) { callback(arg) }
		}
	}
	
	@inlinable public func proceed <T1, T2> (
		with callback: @escaping (T1, T2) -> Void,
		_ arg1: T1,
		_ arg2: T2
	) {
		switch self {
		case .current: callback(arg1, arg2)
		case .onMainThread: execute { callback(arg1, arg2) }
		case .delayed(let ms): execute(in: ms) { callback(arg1, arg2) }
		}
	}
	
	// MARK: In Future
	
	@inlinable public func proceeding(
		with callback: @escaping () -> Void
	) -> () -> Void {
		{ self.proceed(with: callback) }
	}
	
	@inlinable public func proceeding <T> (
		with callback: @escaping (T) -> Void,
		_ arg: T
	) -> () -> Void {
		{ self.proceed(with: callback, arg) }
	}
	
	@inlinable public func proceeding <T> (
		with callback: @escaping (T) -> Void
	) -> (T) -> Void {
		{ arg in self.proceed(with: callback, arg) }
	}
	
	@inlinable public func proceeding <T1, T2> (
		with callback: @escaping (T1, T2) -> Void,
		_ arg1: T1,
		_ arg2: T2
	) -> () -> Void {
		{ self.proceed(with: callback, arg1, arg2) }
	}
	
	@inlinable public func proceeding <T1, T2> (
		with callback: @escaping (T1, T2) -> Void
	) -> (T1, T2) -> Void {
		{ arg1, arg2 in self.proceed(with: callback, arg1, arg2) }
	}
}

public struct MainQueue {
	public typealias Callback = () -> Void
	public typealias CallbackWithValue<T> = (T) -> Void
	public typealias CallbackWithTwoValues<T1, T2> = (T1, T2) -> Void
	public typealias CallbackWithThreeValues<T1, T2, T3> = (T1, T2, T3) -> Void

	@inlinable public static func call(in milliseconds: Int, execute work: @escaping Callback) {
		DispatchQueue.main.asyncAfter(
			deadline: .now() + .milliseconds(milliseconds),
			execute: work
		)
	}
	
	@inlinable public static func function(calling work: @escaping Callback, in milliseconds: Int) -> Callback {{
		DispatchQueue.main.asyncAfter(
			deadline: .now() + .milliseconds(milliseconds),
			execute: work
		)
	}}
	
	@inlinable public static func execute(_ work: @escaping Callback) {
		DispatchQueue.main.async(execute: work)
	}
	
	@inlinable public static func function(executing work: @escaping Callback) -> Callback {{
		DispatchQueue.main.async(execute: work)
	}}
	
	@inlinable public static func function<T>(executing work: @escaping CallbackWithValue<T>) -> CallbackWithValue<T> {
		{ t in
			DispatchQueue.main.async {
				work(t)
			}
		}
	}
	
	@inlinable public static func function<T1, T2>(executing work: @escaping CallbackWithTwoValues<T1, T2>) -> CallbackWithTwoValues<T1, T2> {
		{ t1, t2 in
			DispatchQueue.main.async {
				work(t1, t2)
			}
		}
	}
	
	// TODO: Finish for 3 values, do the same for `function(calling:in:)`")
}
