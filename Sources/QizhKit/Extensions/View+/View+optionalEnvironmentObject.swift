//
//  View+optionalEnvironmentObject.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 18.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	@ViewBuilder
	public func environmentObject<B>(optional observable: B?) -> some View
		where B: ObservableObject
	{
		if let observable {
			self.environmentObject(observable)
		} else {
			self
		}
	}
}
