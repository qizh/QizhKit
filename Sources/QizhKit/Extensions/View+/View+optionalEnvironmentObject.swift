//
//  View+optionalEnvironmentObject.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 18.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension View {
	func environmentObject<B>(optional observable: B?) -> some View where B: ObservableObject {
		observable.map(view: environmentObject) ?? self
	}
	
	/*
	func environmentObject<B>(_ bindable: B?) -> some View where B: ObservableObject {
		bindable.mapView { bin in
			self.environmentObject(bin)
		} ?? self
	}
	*/
	
	/*
	@ViewBuilder func environmentObject<B>(_ bindable: B?) -> some View where B: ObservableObject {
		if bindable.isSet {
			self.environmentObject(bindable)
		} else {
			self
		}
	}
	*/
}
