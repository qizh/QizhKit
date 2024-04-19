//
//  ButtonStyleModifier.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 27.11.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public protocol ButtonStyleDisableable 				{ var isEnabled: Bool 			{ get set } }
public protocol ButtonStyleColorSchemeDependable 	{ var colorScheme: ColorScheme 	{ get set } }
public protocol ButtonStyleHighlighted 				{ var highlightColor: Color? 	{ get set } }
public protocol ButtonStyleSelectable 				{ var selected: Bool 			{ get set } }
public protocol ButtonStyleCurrentFontAware 		{ var font: Font? 				{ get set } }
public protocol ButtonStyleHoverable 				{ var isHovering: Bool 			{ get set } }
public protocol ButtonStylePlaceholderable 			{ var isPlaceholder: Bool 		{ get set } }

public struct ButtonStyleModifier<Style: ButtonStyle>: ViewModifier {
	@Environment(\.isEnabled) 			private var isEnabled: Bool
	@Environment(\.colorScheme) 		private var colorScheme: ColorScheme
	@Environment(\.highlightColor) 		private var highlightColor: Color?
	@Environment(\.selected) 			private var selected: Bool
	@Environment(\.font) 				private var font: Font?
	@Environment(\.redactionReasons) 	private var redactionReasons: RedactionReasons
	
	@State private var isHovering: Bool = false
	
	private let style: Style
	
	public init(style: Style) {
		self.style = style
	}
	
	public func body(content: Content) -> some View {
		content
			.buttonStyle(updatedStyle())
			.onHover { hovering in
				isHovering = hovering
			}
	}
	
	private func updatedStyle() -> Style {
		var updated = style
		
		var disablable = updated as? ButtonStyleDisableable
		disablable?.isEnabled = isEnabled
		updated = (disablable as? Style) ?? updated
		
		var colorSchemable = updated as? ButtonStyleColorSchemeDependable
		colorSchemable?.colorScheme = colorScheme
		updated = (colorSchemable as? Style) ?? updated
		
		var highlightColorable = updated as? ButtonStyleHighlighted
		highlightColorable?.highlightColor = highlightColor
		updated = (highlightColorable as? Style) ?? updated
		
		var selectable = updated as? ButtonStyleSelectable
		selectable?.selected = selected
		updated = (selectable as? Style) ?? updated
		
		var fontAware = updated as? ButtonStyleCurrentFontAware
		fontAware?.font = font
		updated = (fontAware as? Style) ?? updated
		
		var hoverable = updated as? ButtonStyleHoverable
		hoverable?.isHovering = isHovering
		updated = (hoverable as? Style) ?? updated
		
		var placeholderable = updated as? ButtonStylePlaceholderable
		placeholderable?.isPlaceholder = redactionReasons.contains(.placeholder)
		updated = (placeholderable as? Style) ?? updated
		
		return updated
	}
}
