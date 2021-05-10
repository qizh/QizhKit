//
//  View+background+overlay.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 29.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Background, Overlay

public extension View {
	@inlinable
	func background <Background> (
		_ alignment: Alignment,
		_ view: Background
	) -> some View where Background: View {
		background(view, alignment: alignment)
	}
	
	@inlinable
	func overlay <Overlay> (
		_ alignment: Alignment,
		_ view: Overlay
	) -> some View where Overlay: View {
		overlay(view, alignment: alignment)
	}
	
	@inlinable
	func background <Background> (
		_ alignment: Alignment = .center,
		@ViewBuilder view: () -> Background
	) -> some View where Background: View {
		background(view(), alignment: alignment)
	}
	
	@inlinable
	func overlay <Overlay> (
		_ alignment: Alignment = .center,
		@ViewBuilder view: () -> Overlay
	) -> some View where Overlay: View {
		overlay(view(), alignment: alignment)
	}
}

// MARK: Library Content

@available(iOS 14.0, *)
public struct BackgroundAndOverlaySugarLibraryContent: LibraryContentProvider {
	@LibraryContentBuilder
	public func modifiers <Base: View> (base: Base) -> [LibraryItem] {
		[
			LibraryItem(
				base.overlay(.center, Text("Overlay")),
				title: "Overlay view",
				category: .layout,
				matchingSignature: "overlay(_:_:)"
			),
			LibraryItem(
				base.overlay(.center) {
					Text("Overlay")
				},
				title: "Overlay view builder",
				category: .layout,
				matchingSignature: "overlay(_:view:)"
			),
			LibraryItem(
				base.background(.center, Color.secondarySystemFill),
				title: "Background view",
				category: .layout,
				matchingSignature: "background(_:_:)"
			),
			LibraryItem(
				base.background(.center) {
					Color.secondarySystemFill
				},
				title: "Background view builder",
				category: .layout,
				matchingSignature: "background(_:view:)"
			),
		]
	}
}

// MARK: Deprecated

public extension View {
	@available(*, deprecated, renamed: "background(_:_:)")
	@inlinable
	func background<Background>(aligned: Alignment, _ view: Background) -> some View where Background: View {
		background(view, alignment: aligned)
	}
	
	@available(*, deprecated, renamed: "overlay(_:_:)")
	@inlinable
	func overlay<Overlay>(aligned: Alignment, _ view: Overlay) -> some View where Overlay: View {
		overlay(view, alignment: aligned)
	}
	
	@available(*, deprecated, renamed: "background(_:view:)")
	@inlinable
	func background <Background: View> (
		aligned alignment: Alignment,
		@ViewBuilder _ content: () -> Background
	) -> some View {
		background(content(), alignment: alignment)
	}
	
	@available(*, deprecated, renamed: "overlay(_:view:)")
	@inlinable
	func overlay <Overlay: View> (
		aligned alignment: Alignment,
		@ViewBuilder _ content: () -> Overlay
	) -> some View {
		overlay(content(), alignment: alignment)
	}
}

// MARK: Background Color

public extension View {
	@inlinable
	func backgroundColor(_ color: Color) -> some View {
		background(color)
	}
	
	@inlinable
	func backgroundColor(_ key: BorderCrafterValues.UIColors.Key) -> some View {
		background(Color(BorderCrafterValues.UIColors.value(for: key)))
	}
	
	// MARK: > Regular
		
	/// White for default ColorScheme
	@inlinable
	func systemBackground() -> some View {
		background(Color(.systemBackground))
	}
	
	/// Light Gray for default ColorScheme
	@inlinable
	func secondarySystemBackground() -> some View {
		background(Color(.secondarySystemBackground))
	}

	// MARK: > Inverted
	
	/// Black for default ColorScheme
	@inlinable
	func backgroundLabelColor() -> some View {
		background(Color(.label))
	}
	
	/// Dark Gray for default ColorScheme
	@inlinable
	func backgroundSecondaryLabelColor() -> some View {
		background(Color(.secondaryLabel))
	}
	
	// MARK: > Accent
	
	@inlinable
	func backgroundAccentColor() -> some View {
		background(Color.accentColor)
	}
	
	// MARK: > Deprecated
	
	@available(*, deprecated, renamed: "backgroundLabelColor", message: "Use `backgroundLabelColor` instead")
	@inlinable
	func labelBackground() -> some View {
		background(Color(.label))
	}
	
	@available(*, deprecated, renamed: "backgroundSecondaryLabelColor", message: "Use `backgroundSecondaryLabelColor` instead")
	@inlinable
	func secondaryLabelBackground() -> some View {
		background(Color(.secondaryLabel))
	}
	
	@available(*, deprecated, renamed: "backgroundAccentColor", message: "Use `backgroundAccentColor` instead")
	@inlinable
	func accentBackground() -> some View {
		background(Color.accentColor)
	}
}

// MARK: Foreground Color

public extension View {
	@inlinable func foregroundColor(_ key: BorderCrafterValues.UIColors.Key) -> some View {
		foregroundColor(Color(BorderCrafterValues.UIColors.value(for: key)))
	}
	
	// MARK: > Regular
	
	/// Black for default ColorScheme
	@inlinable func foregroundLabel() -> some View {
		foregroundColor(Color(.label))
	}
	
	/// Dark Gray for default ColorScheme
	@inlinable func foregroundSecondaryLabel() -> some View {
		foregroundColor(Color(.secondaryLabel))
	}
	
	// MARK: > Inverted
	
	/// White for default ColorScheme
	@inlinable func foregroundSystemBackground() -> some View {
		foregroundColor(Color(.systemBackground))
	}
	
	/// > Light Gran for default ColorScheme
	@inlinable func foregroundSecondarySystemBackground() -> some View {
		foregroundColor(Color(.secondarySystemBackground))
	}
	
	// MARK: > Accent
	
	@inlinable func foregroundAccent() -> some View { foregroundColor(.accentColor) }
	
	// MARK: > Common
	
	@inlinable func foregroundWhite() -> some View { foregroundColor(.white) }
	@inlinable func foregroundBlack() -> some View { foregroundColor(.black) }
	@inlinable func foregroundPlaceholder() -> some View { foregroundColor(Color(.placeholderText)) }
	
	// MARK: > Deprecated
	
	@available(*, deprecated, renamed: "foregroundAccent", message: "Use `foregroundAccent` instead")
	@inlinable
	func accentForeground() -> some View {
		foregroundColor(.accentColor)
	}
	
	@available(*, deprecated, renamed: "foregroundLabel", message: "Use `foregroundLabel` instead")
	@inlinable
	func labelForeground() -> some View {
		foregroundColor(Color(.label))
	}
	
	@available(*, deprecated, renamed: "foregroundSecondaryLabel", message: "Use `foregroundSecondaryLabel` instead")
	@inlinable
	func secondaryLabelForeground() -> some View {
		foregroundColor(Color(.secondaryLabel))
	}
}

public extension Text {
	@inlinable func foregroundColor(_ key: BorderCrafterValues.UIColors.Key) -> Text {
		foregroundColor(Color(BorderCrafterValues.UIColors.value(for: key)))
	}
	
	// MARK: > Regular
	
	/// Black for default ColorScheme
	@inlinable func foregroundLabel() -> Text {
		foregroundColor(Color(.label))
	}
	
	/// Dark Gray for default ColorScheme
	@inlinable func foregroundSecondaryLabel() -> Text {
		foregroundColor(Color(.secondaryLabel))
	}
	
	// MARK: > Inverted
	
	/// White for default ColorScheme
	@inlinable func foregroundSystemBackground() -> Text {
		foregroundColor(Color(.systemBackground))
	}
	
	/// > Light Gran for default ColorScheme
	@inlinable func foregroundSecondarySystemBackground() -> Text {
		foregroundColor(Color(.secondarySystemBackground))
	}
	
	// MARK: > Accent
	
	@inlinable func foregroundAccent() -> Text { foregroundColor(.accentColor) }
	
	// MARK: > Common
	
	@inlinable func foregroundWhite() -> Text { foregroundColor(.white) }
	@inlinable func foregroundBlack() -> Text { foregroundColor(.black) }
	@inlinable func foregroundPlaceholder() -> Text { foregroundColor(Color(.placeholderText)) }
}

// MARK: Max

public extension View {
	@inlinable func maxWidth(_ value: CGFloat? = .infinity, _ alignment: Alignment = .leading) -> some View {
		frame(maxWidth: value, alignment: alignment)
	}
	@inlinable func maxWidth(_ alignment: Alignment = .leading) -> some View {
		frame(maxWidth: .infinity, alignment: alignment)
	}
	@inlinable func minWidth(_ value: CGFloat? = nil, _ alignment: Alignment = .leading) -> some View {
		frame(minWidth: value, alignment: alignment)
	}
	
	@inlinable func maxHeight(_ value: CGFloat? = .infinity, _ alignment: Alignment = .top) -> some View {
		frame(maxHeight: value, alignment: alignment)
	}
	@inlinable func maxHeight(_ alignment: Alignment = .top) -> some View {
		frame(maxHeight: .infinity, alignment: alignment)
	}
	@inlinable func minHeight(_ value: CGFloat? = nil, _ alignment: Alignment = .top) -> some View {
		frame(minHeight: value, alignment: alignment)
	}
	
	@inlinable func maxSize(_ value: CGSize? = .infinity, _ alignment: Alignment = .topLeading) -> some View {
		frame(maxWidth: value?.width, maxHeight: value?.height, alignment: alignment)
	}
	@inlinable func minSize(_ value: CGSize? = nil, _ alignment: Alignment = .topLeading) -> some View {
		frame(minWidth: value?.width, minHeight: value?.height, alignment: alignment)
	}

	@inlinable func maxSquare(_ size: CGFloat = .infinity, _ alignment: Alignment = .center) -> some View {
		frame(maxWidth: size, maxHeight: size, alignment: alignment)
	}
	
	@inlinable func expand(_ alignment: Alignment = .center) -> some View {
		frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
	}
	
	@inlinable func ideal(_ size: CGSize?, _ alignment: Alignment = .center) -> some View {
		frame(idealWidth: size?.width, idealHeight: size?.height, alignment: alignment)
	}
	
	// MARK: > Deprecated
	
	@available(*, deprecated, renamed: "maxWidth(_:alignment:)", message: "Use `maxWidth` instead")
	@inlinable
	func frameMaxWidth(alignment: Alignment = .center) -> some View {
		frame(maxWidth: .infinity, alignment: alignment)
	}
	
	@available(*, deprecated, renamed: "maxHeight(_:alignment:)", message: "Use `maxHeight` instead")
	@inlinable
	func frameMaxHeight(alignment: Alignment = .center) -> some View {
		frame(maxHeight: .infinity, alignment: alignment)
	}
	
	@available(*, deprecated, renamed: "expand(_:)", message: "Use `expand` instead. Or `maxSize` is you want to specify the maximum size.")
	@inlinable
	func frameMax(alignment: Alignment = .center) -> some View {
		frame(maxWidth: .infinity, maxHeight: .infinity, alignment: alignment)
	}
}

// MARK: Zero

public extension View {
	@inlinable
	func size0() -> some View {
		frame(width: 0, height: 0)
	}
	
	@inlinable
	func sizeZero() -> some View {
		frame(width: 0, height: 0)
	}
	
	// MARK: > Deprecated
	
	@available(*, deprecated, renamed: "sizeZero()", message: "Use `sizeZero` instead")
	@inlinable
	func frameZero() -> some View {
		frame(width: 0, height: 0)
	}
	
	@available(*, deprecated, renamed: "size0()", message: "Use `size0` instead")
	@inlinable
	func frame0() -> some View {
		frame(width: 0, height: 0)
	}
	
	@available(*, deprecated, renamed: "sizeZero()", message: "Use `sizeZero` instead")
	@inlinable
	func zeroSize() -> some View {
		frame(width: 0, height: 0)
	}
}

// MARK: Width, Height, Size

public extension View {
	@inlinable
	func width(_ value: CGFloat? = nil, _ alignment: Alignment = .center) -> some View {
		frame(width: value, alignment: alignment)
	}
	
//	@inlinable
	func height(_ value: CGFloat? = nil, _ alignment: Alignment = .center) -> some View {
		frame(height: value, alignment: alignment)
	}
	
	@inlinable
	func size(_ value: CGSize? = nil, _ alignment: Alignment = .center) -> some View {
		frame(width: value?.width, height: value?.height, alignment: alignment)
	}
	
	@inlinable func size(_ width: CGFloat?, _ height: CGFloat?, _ alignment: Alignment = .center) -> some View {
		frame(width: width, height: height, alignment: alignment)
	}
	
	@inlinable func size(_ width: Int?, _ height: Int?, _ alignment: Alignment = .center) -> some View {
		frame(width: width?.cg, height: height?.cg, alignment: alignment)
	}
	
	@inlinable func square(_ size: CGFloat? = nil, _ alignment: Alignment = .center) -> some View {
		frame(width: size, height: size, alignment: alignment)
	}
	
	@inlinable
	func fixedWidth() -> some View {
		fixedSize(horizontal: true, vertical: false)
	}
	
	@inlinable
	func fixedHeight() -> some View {
		fixedSize(horizontal: false, vertical: true)
	}

	// MARK: > Deprecated
	
	/// Square frame
	/// - Parameter side: `CGFloat` value that will be aplied to both, `width` and `height`
	@available(*, deprecated, renamed: "square(_:_:)", message: "Use `square` instead")
	@inlinable
	func frame(side: CGFloat, alignment: Alignment = .center) -> some View {
		frame(width: side, height: side, alignment: alignment)
	}
	
	@available(*, deprecated, renamed: "maxSize(_:alignment:)", message: "Use `maxSize` instead")
	@inlinable
	func limitSize(_ value: CGSize?, alignment: Alignment = .center) -> some View {
		frame(maxWidth: value?.width, maxHeight: value?.height, alignment: alignment)
	}
	
	@available(*, deprecated, renamed: "size(_:_:)", message: "Use `size` instead")
	@inlinable
	func frame(size: CGSize, alignment: Alignment = .center) -> some View {
		frame(width: size.width, height: size.height, alignment: alignment)
	}
}
