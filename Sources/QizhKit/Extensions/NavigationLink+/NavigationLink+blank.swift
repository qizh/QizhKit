//
//  NavigationLink+blank.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 26.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension NavigationLink where Label == Pixel {
	@inlinable
	public init(_ destination: Destination) {
		self.init(destination: destination) {
			Pixel()
		}
	}
	
	@inlinable
	public init(destination: Destination) {
		self.init(destination: destination) {
			Pixel()
		}
	}
	
	@inlinable
	public init(destination: Destination, isActive: Binding<Bool>) {
		self.init(destination: destination, isActive: isActive) {
			Pixel()
		}
	}
}

extension NavigationLink where Label == EmptyView, Destination == EmptyView {
	@inlinable
	public static var empty: Self {
		NavigationLink(destination: EmptyView()) {
			EmptyView()
		}
	}
}
