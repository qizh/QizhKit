//
//  Bool+output.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 08.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Bool {
	var sign: Character {
		self ? .boltChar : .xMarkChar
	}
	
	var imageCircle: some View {
		Image(systemName: self ? "checkmark.circle" : "xmark.circle")
			.foregroundColor(self ? .green : .red)
	}
}
