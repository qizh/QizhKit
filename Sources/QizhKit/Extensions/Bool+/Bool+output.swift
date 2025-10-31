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
	
	/// `1` for `true`, `0` for `false`
	@inlinable public var asInt: Int8 {
		self ? 1 : 0
	}
	
	/// `1` for `true`, `-1` for `false`
	@inlinable public var asIntSign: Int {
		self ? 1 : -1
	}
}
