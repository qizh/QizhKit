//
//  BlurTransition.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 08.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct BlurModifier: ViewModifier {
	public let radius: CGFloat

	public func body(content: Content) -> some View {
		content.blur(radius: radius)
	}
}

public extension AnyTransition {
	static var blur: AnyTransition {
		blur()
	}
	
	static func blur(radius: CGFloat = 6) -> AnyTransition {
		AnyTransition.modifier(
			active: BlurModifier(radius: radius),
			identity: BlurModifier(radius: 0)
		)
	}
}
