//
//  View+multiplied.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 18.07.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

public import SwiftUI

extension View {
	@inlinable public func multiplied(
		@Clamped(range: 1...20) by multiplier: Int = 2,
		using layout: some Layout
	) -> some View {
		layout {
			self.multiplied(by: multiplier)
		}
	}
	
	@inlinable public func multiplied(
		@Clamped(range: 1...20) by multiplier: Int = 2
	) -> some View {
		ForEach(0 ... multiplier, id: \.self) { _ in
			self
		}
	}
}
