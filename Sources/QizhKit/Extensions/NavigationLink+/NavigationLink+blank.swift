//
//  NavigationLink+blank.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 26.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension NavigationLink where Label == Pixel {
	@inlinable init(_ destination: Destination) {
		self.init(destination: destination) {
			Pixel()
		}
	}
	
	@inlinable init(destination: Destination) {
		self.init(destination: destination) {
			Pixel()
		}
	}
	
	@inlinable init(destination: Destination, isActive: Binding<Bool>) {
		self.init(destination: destination, isActive: isActive) {
			Pixel()
		}
	}
}

public extension NavigationLink where Label == Text {
	@inlinable init<S>(_ title: S, destination: Destination)
		where S: StringProtocol
	{
		self.init(destination: destination, label: { Text(title) })
	}
	
	@inlinable init<S>(_ title: S, destination: Destination, isActive: Binding<Bool>)
		where S: StringProtocol
	{
		self.init(destination: destination, isActive: isActive, label: { Text(title) })
	}
}

/*
public extension NavigationLink where Label == Pixel {
	@inlinable static func Pixel(
		destination: Destination,
		isActive: Binding<Bool>
	) -> NavigationLink {
		NavigationLink(destination: destination, isActive: isActive, label: Label.init)
	}
}
*/
