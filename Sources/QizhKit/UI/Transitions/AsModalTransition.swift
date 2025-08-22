//
//  AsModalTransition.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct HalfModalStyleModifier: ViewModifier {
	private let factor: Factor
	private let radius: CGFloat
	
	@Environment(\.colorScheme) private var colorScheme: ColorScheme
	
	public init(
		radius: CGFloat = CGFloat.hundred.quater,
		factor: Factor
	) {
		self.radius = radius
		self.factor = factor
	}
	
//	@ViewBuilder
	public func body(content: Content) -> some View {
		GeometryReader { geometry in
			content
				.round((1 - ((factor.cg - 0.9) * 10).zeroOneClipped) * radius, .top)
				.shadow(color: shadowColor, radius: radius)
				.offset(y: geometry.size.height * (1 - factor.cg))
		}
	}
	
	/*
	private var modalBackground: Color {
		colorScheme.isDark ? .secondarySystemBackground : .systemBackground
	}
	*/
	
	private var shadowColor: Color {
		colorScheme.isDark ? .clear : .label(factor.value * 0.20)
	}

}

public extension AnyTransition {
	@MainActor static var asModal: AnyTransition {
		.modifier(
			  active: HalfModalStyleModifier(factor: .zero),
			identity: HalfModalStyleModifier(factor: .one)
		)
	}
}

// MARK: Previews

#if DEBUG
fileprivate struct DemoView: View {
	let name: String
	
	init(_ name: String) {
		self.name = name
	}
	
	var body: some View {
		Text(name)
			.expand(.center)
			.round(10, border: .yellow)
			.padding()
	}
}

struct AsModalTransition_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			DemoView("Preview 100%")
				.modifier(HalfModalStyleModifier(factor: .one))
				.previewDisplayName("100%")
			DemoView("Preview 95%")
				.modifier(HalfModalStyleModifier(factor: 0.95))
				.previewDisplayName("95%")
			DemoView("Preview 66%")
				.modifier(HalfModalStyleModifier(factor: 0.66))
				.previewDisplayName("66%")
			DemoView("Preview 33%")
				.modifier(HalfModalStyleModifier(factor: 0.33))
				.previewDisplayName("33%")
			DemoView("Preview 5%")
				.modifier(HalfModalStyleModifier(factor: 0.05))
				.previewDisplayName("5%")
			DemoView("Preview 0%")
				.modifier(HalfModalStyleModifier(factor: .zero))
				.previewDisplayName("0%")
		}
		.previewLayout(.fixed(width: 200, height: 200))
	}
}
#endif
