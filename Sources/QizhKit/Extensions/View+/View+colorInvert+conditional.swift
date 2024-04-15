//
//  View+colorInvert+conditional.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.11.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func colorInvert(_ apply: Bool) -> some View {
		if apply {
			self.colorInvert()
		} else {
			self
		}
	}
}
