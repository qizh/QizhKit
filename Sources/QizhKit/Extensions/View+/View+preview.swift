//
//  View+previewColorSchemes.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 13.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension View {
	@inlinable func previewAllColorSchemes(
		_ enabled: Bool = true,
		names: Bool = false
	) -> some View {
		ForEach(enabled ? ColorScheme.allCases : [.default]) { scheme in
			self.colorScheme(scheme)
				.previewDisplayName(names ? scheme.name : nil)
		}
	}
	
	@inlinable func previewDifferentDevices(names: Bool = false) -> some View {
		ForEach(["iPhone 11", "iPhone SE (2nd generation)", "iPhone 8 Plus", "iPhone 11 Pro"], id: \.self) { name in
			self.previewDevice(.init(stringLiteral: name))
				.previewDisplayName(names ? name : nil)
		}
	}
	
	@inlinable func previewsWithFonts(_ fonts: Font ...) -> some View {
		ForEach(enumerating: fonts) { _, font in
			self.font(font)
		}
	}
	
	@inlinable func previewVertically() -> some View {
		ScrollView(.vertical) {
			VStack(alignment: .leading, spacing: 2) {
				self.systemBackground()
			}
			.backgroundColor(.gray)
		}
	}
	
	@inlinable func previewHorizontally(width: CGFloat = 400, fit: Bool) -> some View {
		ScrollView(.horizontal) {
			HStack(alignment: .top, spacing: 2) {
				self.width(width, .topLeading)
					.systemBackground()
			}
			.backgroundColor(.gray)
		}
		.fixedSize(horizontal: fit, vertical: false)
		.previewFitting(padding: fit ? .vertical : [])
	}
	
	@inlinable func previewDemoLocales() -> some View {
		previewLocales("en_US", "ru_UA", "th_TH")
	}
	
	@inlinable func previewLocales(_ codes: String ...) -> some View {
		previewLocales(codes.map(Locale.init))
	}
	
	@inlinable func previewLocales(_ locales: Locale ...) -> some View {
		previewLocales(locales)
	}
	
	@inlinable func previewLocales(_ locales: [Locale]) -> some View {
		ForEach(enumerating: locales) { _, locale in
			self.environment(\.locale, locale)
				.previewDisplayName(locale.identifier)
		}
	}
	
	@inlinable func previewFitting(
		padding edges: Edge.Set = .all,
		color: Color = Color(.systemBackground)
	) -> some View {
		self
			.padding(edges)
			.background(color)
			.previewLayout(.sizeThatFits)
	}
	
	@inlinable func previewBig() -> some View {
		self
			.padding()
			.background(Color(.systemBackground))
			.previewLayout(.fixed(width: 600, height: 900))
	}
}
