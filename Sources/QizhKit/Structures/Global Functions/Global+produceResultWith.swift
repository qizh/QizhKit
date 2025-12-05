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
public nonisolated func produceResult<T, R>(
	with calculatedValue: T,
	andCreate result: (T) -> R
) -> R {
	result(calculatedValue)
}

/*
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
*/

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
public nonisolated func produceResult<T, each P, R>(
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
public nonisolated func produceResultWith<T>(_ calculation: @autoclosure () -> T) -> T {
	calculation()
}

#if swift(>=5.9)

// MARK: ┣ Variadic Generics

/// Produces a value by first supplying a lazily-evaluated tuple of parameters
/// and then applying a calculation that consumes those parameters.
///
/// This overload leverages variadic generics to support any number of input parameters
/// without requiring multiple function variants. The `parameter` closure is invoked
/// exactly once to obtain the input values, which are then forwarded to `calculation`.
/// ## Example:
/// ```swift
/// let sum = produceResult {
/// 	(3, 5)
/// } useResult: { (a: Int, b: Int) in
/// 	a + b
/// }
/// /// sum == 8
/// ```
/// - Parameters:
///   - parameter: A closure that returns a variadic tuple of input parameters
///     (`repeat each P`). This closure is evaluated once to produce the inputs
///     for the calculation.
///   - calculation: A closure that accepts the expanded variadic parameters
///     and produces a result of type `T`.
/// - Returns: The value produced by applying `calculation`
///   to the parameters returned by `parameter`.
/// - Note: This function is available when compiling with Swift `5.9` or later,
///   where variadic generics are supported.
/// - Complexity: `O(1)` for invoking both closures.
///   Overall cost depends on the work performed inside `calculation`.
public nonisolated func produceResult<T, each P>(
	_ parameter: () -> (repeat each P),
	useResult calculation: (repeat each P) -> T
) -> T {
	calculation(repeat each parameter())
}

/// Executes a calculation that depends on multiple variadic parameters
/// and returns its result.
///
/// - Parameters:
///   - parameter: A variadic list of parameters of generic types.
///   - calculation: A closure that computes a value of type `T`
///   		from the provided parameters.
/// - Returns: The computed value of type `T`.
public nonisolated func produceResultWith<T, each P>(
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
