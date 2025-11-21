//
//  Bool+output.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 08.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension Bool {
	public var emoji: Character {
		self ? .checkmarkEmojiChar : .xmarkEmojiChar
	}
	
	public var sign: Character {
		self ? .boltChar : .xMarkChar
	}
	
	public var mark: Character {
		self ? .checkMarkChar : .xMarkChar
	}
	
	@MainActor
	public var imageCircle: some View {
		if self {
			Image(systemName: "checkmark.circle")
				.foregroundStyle(.green)
		} else {
			Image(systemName: "xmark.circle")
				.foregroundStyle(.red)
		}
	}
	
	/// Returns `1` for `true`, `0` for `false`.
	///
	/// - Returns: `1` if `self` is `true`, otherwise `0`.
	@inlinable public var asInt: Int8 {
		self ? 1 : 0
	}
	
	/// Returns `1` for `true`, `-1` for `false`.
	///
	/// - Returns: `1` if `self` is `true`, otherwise `-1`.
	/// - Discussion:
	///   Useful for applying a sign to calculations or animations
	///   based on a boolean condition.
	@inlinable public var asIntSign: Int {
		self ? 1 : -1
	}
}
