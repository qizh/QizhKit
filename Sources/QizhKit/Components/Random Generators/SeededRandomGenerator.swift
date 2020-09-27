//
//  SeededRandomGenerator.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 25.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import GameplayKit

/*
public final class SeededGenerator: RandomNumberGenerator {
//	public let seed: UInt64
	private let generator: GKMersenneTwisterRandomSource
	
	/*
	@inlinable public convenience init() {
		self.init(seed: 0)
	}
	*/
	
	public init(seed: UInt64) {
//		self.seed = seed
		self.generator = GKMersenneTwisterRandomSource(seed: seed)
	}
	
	/*
	public func next(upperBound: UInt) -> UInt {
		UInt(abs(generator.nextInt(upperBound: Int(upperBound))))
	}
	
	public func next() -> UInt {
		UInt(abs(generator.nextInt()))
	}
	*/
	
	public func next<Value>(upperBound: Value) -> Value where Value: FixedWidthInteger, Value: UnsignedInteger {
		Value(abs(generator.nextInt(upperBound: Int(upperBound))))
	}
	
	public func next<Value>() -> Value where Value: FixedWidthInteger, Value: UnsignedInteger {
		Value(abs(generator.nextInt()))
	}
}
*/

public struct SeededRandomGenerator: RandomNumberGenerator {
	public mutating func next() -> UInt64 {
		// GKRandom produces values in [INT32_MIN, INT32_MAX] range; hence we need two numbers to produce 64-bit value.
		let next1 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
		let next2 = UInt64(bitPattern: Int64(gkrandom.nextInt()))
		return next1 ^ (next2 << 32)
	}
	
	public init(seed: UInt64) {
		self.gkrandom = GKMersenneTwisterRandomSource(seed: seed)
	}
	
	private let gkrandom: GKRandom
}
