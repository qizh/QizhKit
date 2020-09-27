//
//  LazyView.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct LazyView<Heavy: View>: View {
	let produce: () -> Heavy
	
	public init(_ view: @autoclosure @escaping () -> Heavy) {
		self.produce = view
	}
	
	public var body: Heavy {
		produce()
	}
}

public extension View {
	@inlinable func lazy() -> LazyView<Self> {
		LazyView(self)
	}
}
