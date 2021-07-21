//
//  Shape+sugar.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 23.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	@inlinable public func clipCircle() -> some View {
		clipShape(Circle())
	}
}
