//
//  Global+produceResultWith.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.05.2024.
//  Copyright © 2024 Bespokely. All rights reserved.
//

import Foundation

// MARK: Produce Result & Create

/// Produces a result by applying the given `result` closure to a provided calculated value.
///
/// - Parameters:
///   - calculatedValue: The already computed value of type `T`.
///   - result: A closure that creates a result of type `R` from the calculated value.
/// - Returns: The result produced by the `result` closure.
public func produceResult<T, R>(
	with calculatedValue: T,
	andCreate result: (T) -> R
) -> R {
	result(calculatedValue)
}

/// Produces a result by first lazily computing a value using an autoclosure
/// and then applying the provided `result` closure.
///
/// - Parameters:
///   - calculation: An autoclosure that computes a value of type `T`.
///   - result: A closure that converts the computed value into a result of type `R`.
/// - Returns: The result produced by the `result` closure.
public func produceResult<T, R>(
	making calculation: @autoclosure () -> T,
	andCreate result: (T) -> R
) -> R {
	result(calculation())
}

#if swift(>=5.9)

// MARK: ┣ Variadic Generics

/// Produces a result by computing a value from multiple parameters using variadic generics,
/// then applying the given `result` closure.
///
/// - Parameters:
///   - parameter: A variadic list of parameters.
///   - calculation: A closure that computes a value of type `T` from the given parameters.
///   - result: A closure that converts the computed value into a result of type `R`.
/// - Returns: The result produced by the `result` closure.
public func produceResult<T, each P, R>(
	for parameter: repeat each P,
	with calculation: (repeat each P) -> T,
	andCreate result: (T) -> R
) -> R {
	result(calculation(repeat each parameter))
}

#endif

// MARK: Produce Result

// MARK: ┣ No parameter

/// Executes the provided calculation and returns its result.
///
/// This function is useful when the calculation is complex
/// and needs to be performed only once.
///
/// - Parameter calculation: An autoclosure that computes a value of type `T`.
/// - Returns: The computed value of type `T`.
public func produceResultWith<T>(_ calculation: @autoclosure () -> T) -> T {
	calculation()
}

#if swift(>=5.9)

// MARK: ┣ Variadic Generics

/// Executes a calculation that depends on multiple variadic parameters
/// and returns its result.
///
/// - Parameters:
///   - parameter: A variadic list of parameters of generic types.
///   - calculation: A closure that computes a value of type `T`
///   		from the provided parameters.
/// - Returns: The computed value of type `T`.
public func produceResultWith<T, each P>(
	_ parameter: repeat each P,
	perform calculation: (repeat each P) -> T
) -> T {
	calculation(repeat each parameter)
}

#else

// MARK: ┗ With 1, 2, 3 parameters

/// Executes the provided calculation with a single parameter and returns the result.
///
/// - Parameters:
///   - parameter: A parameter of type `P`.
///   - calculation: A closure that computes a value of type `T` from the parameter.
/// - Returns: The computed value of type `T`.
public func produceResultWith<T, P>(
	_ parameter: P,
	perform calculation: (P) -> T
) -> T {
	calculation(parameter)
}

/// Executes the provided calculation with two parameters and returns the result.
///
/// - Parameters:
///   - p1: The first parameter of type `P1`.
///   - p2: The second parameter of type `P2`.
///   - calculation: A closure that computes a value of type `T` from the two parameters.
/// - Returns: The computed value of type `T`.
public func produceResultWith<T, P1, P2>(
	_ p1: P1,
	_ p2: P2,
	perform calculation: (P1, P2) -> T
) -> T {
	calculation(p1, p2)
}

/// Executes the provided calculation with three parameters and returns the result.
///
/// - Parameters:
///   - p1: The first parameter of type `P1`.
///   - p2: The second parameter of type `P2`.
///   - p3: The third parameter of type `P3`.
///   - calculation: A closure that computes a value of type `T` from the three parameters.
/// - Returns: The computed value of type `T`.
public func produceResultWith<T, P1, P2, P3>(
	_ p1: P1,
	_ p2: P2,
	_ p3: P3,
	perform calculation: (P1, P2, P3) -> T
) -> T {
	calculation(p1, p2, p3)
}

#endif
