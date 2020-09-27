//
//  View+any.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 26.09.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension View {
	@inlinable func asAnyView() -> AnyView { AnyView(self) }
}
