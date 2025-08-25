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
	
	@inlinable public var asInt: Int8 {
		self ? 1 : 0
	}
}
