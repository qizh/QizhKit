//
//  Binding+Bool.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 18.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Binding where Value == Bool {
	@inlinable func turnOn() {
		execute {
			self.wrappedValue = true
		}
	}
	
	@inlinable func turnOff() {
		execute {
			self.wrappedValue = false
		}
	}
	
	@inlinable func toggle() {
		execute {
			self.wrappedValue.toggle()
		}
	}
}
