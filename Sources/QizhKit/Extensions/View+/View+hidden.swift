//
//  View+hidden.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 03.01.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct HiddenViewModifier: ViewModifier {
	private let hidden: Bool
	
	public init(_ hidden: Bool) {
		self.hidden = hidden
	}
	
	@ViewBuilder public func body(content: Content) -> some View {
		if hidden {
			content.hidden()
		} else {
			content
		}
	}
}

public extension View {
    @inlinable func hidden(_ hidden: Bool) -> some View {
		modifier(HiddenViewModifier(hidden))
    }
    @inlinable func visible(_ visible: Bool) -> some View {
		modifier(HiddenViewModifier(!visible))
    }
}

public extension View {
	@ViewBuilder func delete(_ delete: Bool = true) -> some View {
		if delete {
			EmptyView()
		} else {
			self
		}
	}
}

public extension View {
	@inlinable func enabled(_ enabled: Bool) -> some View {
		disabled(!enabled)
	}
}
