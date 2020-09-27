//
//  ContainerSizePreferenceReader.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 22.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct SizePreferenceKey: PreferenceKey {
	public static var defaultValue: CGSize = .zero
	public static func reduce(value: inout CGSize, nextValue: () -> CGSize) {
		value = nextValue()
	}
}

public struct ContainerSizeBindingModifier: ViewModifier {
	@Binding public var size: CGSize
	
	public func body(content: Content) -> some View {
		content
			.background(
				GeometryReader { geometry in
					Color.almostClear
						.transformPreference(SizePreferenceKey.self) { $0 = geometry.size }
						.onPreferenceChange(SizePreferenceKey.self) { self.size = $0 }
				}
			)
	}
}

public struct ContainerSizeCallbackModifier: ViewModifier {
	public typealias Callback = (_ size: CGSize) -> Void
	public var receive: Callback
	
	public func body(content: Content) -> some View {
		content
			.background(
				GeometryReader { geometry in
					Color.almostClear
						.transformPreference(SizePreferenceKey.self) { $0 = geometry.size }
						.onPreferenceChange(SizePreferenceKey.self, perform: self.receive)
				}
			)
	}
}

public extension View {
	func containerSize(_ size: Binding<CGSize>) -> some View {
		modifier(ContainerSizeBindingModifier(size: size))
	}
	func containerSize(_ receive: @escaping ContainerSizeCallbackModifier.Callback) -> some View {
		modifier(ContainerSizeCallbackModifier(receive: receive))
	}
}
