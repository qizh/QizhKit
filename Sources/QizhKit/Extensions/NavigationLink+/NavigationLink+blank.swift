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

@available(iOS 16.0, macOS 13.0, tvOS 16.0, watchOS 9.0, *)
extension NavigationLink where Destination == Never, Label == EmptyView {
	public init<P>(value: P?) where P: Hashable {
		self.init(value: value) {
			EmptyView()
		}
	}
}
