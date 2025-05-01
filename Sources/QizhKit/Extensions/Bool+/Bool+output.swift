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
	
	public var imageCircle: some View {
		Image(systemName: self ? "checkmark.circle" : "xmark.circle")
			.foregroundStyle(self ? .green : .red)
	}
}
