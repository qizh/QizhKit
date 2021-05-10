//
//  View+previewColorSchemes.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 13.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import DeviceKit

extension Device: Identifiable {
	@inlinable public var id: String { description }
	
	public var previewName: String {
		switch self {
		case .iPhoneSE: return "iPhone SE (1st generation)"
		default: return description
		}
	}
}

public extension Collection where Element == Device {
	static var iPhones12: [Device] {
		[
			.iPhone12Mini,
			.iPhone12Pro,
			.iPhone12ProMax,
		]
	}
	
	static var iOS14sizes: [Device] {
		[
			Device.iPhoneSE,
			Device.iPhone8,
			Device.iPhoneXR,
			Device.iPhone12Mini,
			Device.iPhone12Pro,
			Device.iPhone8Plus,
			Device.iPhone11ProMax,
			Device.iPhone12ProMax,

		]
	}
	
	static var iOS14x2sizes: [Device] {
		[
			Device.iPhoneSE,
			Device.iPhone8,
			Device.iPhoneXR,
		]
	}
	
	static var iOS14x3sizes: [Device] {
		[
			Device.iPhone12Mini,
			Device.iPhone12Pro,
			Device.iPhone8Plus,
			Device.iPhone11ProMax,
			Device.iPhone12ProMax,
		]
	}
}

public extension View {
	@inlinable
	func previewAllColorSchemes(
		_ enabled: Bool = true,
		names: Bool = false
	) -> some View {
		ForEach(enabled ? ColorScheme.allCases : [.default]) { scheme in
			self.colorScheme(scheme)
				.previewDisplayName(names ? scheme.name : nil)
		}
	}
	
	@inlinable
	func previewEnabledAndDisabled() -> some View {
		ForEach([true, false], id: \.self) { isEnabled in
			enabled(isEnabled)
		}
	}
	
	@ViewBuilder
	func previewDifferentScreenSizes() -> some View {
		ForEach([Device].iOS14x2sizes) { device in
			self.previewDevice(PreviewDevice(stringLiteral: device.previewName))
				.previewDisplayName(device.previewName + .space + "@2")
		}
		ForEach([Device].iOS14x3sizes) { device in
			self.previewDevice(PreviewDevice(stringLiteral: device.previewName))
				.previewDisplayName(device.previewName + .space + "@3")
		}
	}
	
	@inlinable
	func previewDifferentDevices(
		devices: [Device] = .iPhones12,
		names: Bool = false
	) -> some View {
		ForEach(devices) { device in
			self.previewDevice(PreviewDevice(stringLiteral: device.description))
				.apply(when: names) {
					$0.previewDisplayName(device.description)
				}
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
	
	/// `en_US`, `ru_UA`, `th_TH`, `en_UA`
	@inlinable func previewDemoLocales() -> some View {
		previewLocales("en_US", "ru_UA", "th_TH", "en_UA")
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
