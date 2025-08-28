//
//  String+random.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension String {
	static let numerics = "0123456789"
	static let lowercasedLetters = "abcdefghijklmnopqrstuvwxyz"
	static let uppercasedLetters = lowercasedLetters.uppercased()
	static let letters = lowercasedLetters + uppercasedLetters
	static let alphanumerics = numerics + letters
	static let alphanumericsWithSpaces = alphanumerics + .space
	static let uppercasedAlphanumerics = numerics + uppercasedLetters
	static let lowercasedAlphanumerics = numerics + lowercasedLetters

	static func random(
		_ amount: UInt = .one,
		charactersFrom set: String,
		seed: UInt64 = .random(in: UInt64.min...UInt64.max)
	) -> String {
		(.zero ..< amount)
			.map { offset in
				set.randomElement(seed: seed + UInt64(offset)) ?? .spaceChar
			}
			.asString()
	}
	
	static func randomID(_ length: UInt = .eight) -> String {
		random(length, charactersFrom: alphanumerics)
	}
	
	static func randomUppercaseID(_ length: UInt = .eight) -> String {
		random(length, charactersFrom: uppercasedAlphanumerics)
	}
}
