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
	@inlinable @MainActor func background <Background> (
		_ alignment: Alignment,
		_ view: Background
	) -> some View where Background: View {
		background(view, alignment: alignment)
	}
	
	@inlinable @MainActor func overlay <Overlay> (
		_ alignment: Alignment,
		_ view: Overlay
	) -> some View where Overlay: View {
		overlay(view, alignment: alignment)
	}
	
	@inlinable @MainActor func background <Background> (
		_ alignment: Alignment,
		@ViewBuilder view: () -> Background
	) -> some View where Background: View {
		background(view(), alignment: alignment)
	}
	
	@inlinable @MainActor func overlay <Overlay> (
		_ alignment: Alignment,
		@ViewBuilder view: () -> Overlay
	) -> some View where Overlay: View {
		overlay(view(), alignment: alignment)
	}
	
	@available(iOS, obsoleted: 15, message: "Implemented in SwiftUI")
	@inlinable @MainActor func background <Background> (
		@ViewBuilder view: () -> Background
	) -> some View where Background: View {
		background(view(), alignment: .center)
	}
	
	@available(iOS, obsoleted: 15, message: "Implemented in SwiftUI")
	@inlinable @MainActor func overlay <Overlay> (
		@ViewBuilder view: () -> Overlay
	) -> some View where Overlay: View {
		overlay(view(), alignment: .center)
	}
}

// MARK: Library Content

public struct BackgroundAndOverlaySugarLibraryContent: LibraryContentProvider {
	@LibraryContentBuilder @MainActor
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
	@inlinable @MainActor func background<Background>(
		aligned: Alignment,
		_ view: Background
	) -> some View where Background: View {
		background(view, alignment: aligned)
	}
	
	@available(*, deprecated, renamed: "overlay(_:_:)")
	@inlinable @MainActor func overlay<Overlay>(
		aligned: Alignment,
		_ view: Overlay
	) -> some View where Overlay: View {
		overlay(view, alignment: aligned)
	}
	
	@available(*, deprecated, renamed: "background(_:view:)")
	@inlinable @MainActor func background <Background: View> (
		aligned alignment: Alignment,
		@ViewBuilder _ content: () -> Background
	) -> some View {
		background(content(), alignment: alignment)
	}
	
	@available(*, deprecated, renamed: "overlay(_:view:)")
	@inlinable @MainActor func overlay <Overlay: View> (
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
		background(Color(uiColor: BorderCrafterValues.UIColors.value(for: key)))
	}
	
	// MARK: > Regular
		
	/// White for default ColorScheme
	@inlinable
	func systemBackground() -> some View {
		background(Color(uiColor: .systemBackground))
	}
	
	/// Light Gray for default ColorScheme
	@inlinable
	func secondarySystemBackground() -> some View {
		background(Color(uiColor: .secondarySystemBackground))
	}

	// MARK: > Inverted
	
	/// Black for default ColorScheme
	@inlinable
	func backgroundLabelColor() -> some View {
		background(Color(uiColor: .label))
	}
	
	/// Dark Gray for default ColorScheme
	@inlinable
	func backgroundSecondaryLabelColor() -> some View {
		background(Color(uiColor: .secondaryLabel))
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
		background(Color(uiColor: .label))
	}
	
	@available(*, deprecated, renamed: "backgroundSecondaryLabelColor", message: "Use `backgroundSecondaryLabelColor` instead")
	@inlinable
	func secondaryLabelBackground() -> some View {
		background(Color(uiColor: .secondaryLabel))
	}
	
	@available(*, deprecated, renamed: "backgroundAccentColor", message: "Use `backgroundAccentColor` instead")
	@inlinable
	func accentBackground() -> some View {
		background(Color.accentColor)
	}
}

// MARK: Foreground Color

public extension View {
	/*
	@inlinable func foregroundColor(_ key: BorderCrafterValues.UIColors.Key) -> some View {
		foregroundColor(Color(uiColor: BorderCrafterValues.UIColors.value(for: key)))
	}
	*/
	
	// MARK: > Regular
	
	/// Black for default ColorScheme
	@inlinable func foregroundLabel() -> some View {
		foregroundStyle(.label)
	}
	
	/// Dark Gray for default ColorScheme
	@inlinable func foregroundSecondaryLabel() -> some View {
		foregroundStyle(.secondaryLabel)
	}
	
	// MARK: > Inverted
	
	/// White for default ColorScheme
	@inlinable func foregroundSystemBackground() -> some View {
		foregroundStyle(.systemBackground)
	}
	
	/// > Light Gran for default ColorScheme
	@inlinable func foregroundSecondarySystemBackground() -> some View {
		foregroundStyle(.secondarySystemBackground)
	}
	
	// MARK: > Accent
	
	@available(*, deprecated, renamed: "foregroundStyle(_:)", message: "This function is using deprecated `foregroundColor(_:)` function")
	@inlinable func foregroundAccent() -> some View { foregroundColor(.accentColor) }
	
	/// Setting `foregroundStyle(.secondary)` when on iOS 15
	/// or `foregroundColor(.accentColor)` when on earlier iOS
	@available(*, deprecated, renamed: "foregroundStyle(_:)", message: "Just use `foregroundStyle(.secondary)` instead.")
	@ViewBuilder
	func foregroundAccentOrSecondary() -> some View {
		foregroundStyle(.secondary)
	}
	
	/// Setting `foregroundStyle(.tertiary)` when on iOS 15
	/// or `foregroundColor(.accentColor)` when on earlier iOS
	@available(*, deprecated, renamed: "foregroundStyle(_:)", message: "Just use `foregroundStyle(.tertiary)` instead.")
	@ViewBuilder
	func foregroundAccentOrTertiary() -> some View {
		foregroundStyle(.tertiary)
	}
	
	/// Setting `foregroundStyle(.quaternary)` when on iOS 15
	/// or `foregroundColor(.accentColor)` when on earlier iOS
	@available(*, deprecated, renamed: "foregroundStyle(_:)", message: "Just use `foregroundStyle(.quaternary)` instead.")
	@ViewBuilder
	func foregroundAccentOrQuaternary() -> some View {
		foregroundStyle(.quaternary)
	}
	
	// MARK: > Common
	
	@inlinable func foregroundWhite() -> some View { foregroundStyle(.white) }
	@inlinable func foregroundBlack() -> some View { foregroundStyle(.black) }
	@inlinable func foregroundPlaceholder() -> some View { foregroundStyle(.placeholderText) }
	
	/*
	// MARK: > Deprecated
	
	@available(*, deprecated, renamed: "foregroundAccent", message: "Use `foregroundAccent` instead")
	@inlinable
	func accentForeground() -> some View {
		foregroundColor(.accentColor)
	}
	
	@available(*, deprecated, renamed: "foregroundLabel", message: "Use `foregroundLabel` instead")
	@inlinable
	func labelForeground() -> some View {
		foregroundColor(Color(uiColor: .label))
	}
	
	@available(*, deprecated, renamed: "foregroundSecondaryLabel", message: "Use `foregroundSecondaryLabel` instead")
	@inlinable
	func secondaryLabelForeground() -> some View {
		foregroundColor(Color(uiColor: .secondaryLabel))
	}
	*/
}

public extension Text {
	@available(*, deprecated, renamed: "foregroundStyle(_:)", message: "There's no need to use KeyPath anymore. Just use the style directly.")
	@inlinable func foregroundColor(_ key: BorderCrafterValues.UIColors.Key) -> Text {
		foregroundColor(Color(uiColor: BorderCrafterValues.UIColors.value(for: key)))
	}
	
	// MARK: > Regular
	
	/// Black for default ColorScheme
	@inlinable func foregroundLabel() -> Text {
		foregroundStyle(.label)
	}
	
	/// Dark Gray for default ColorScheme
	@inlinable func foregroundSecondaryLabel() -> Text {
		foregroundStyle(.secondaryLabel)
	}
	
	// MARK: > Inverted
	
	/// White for default ColorScheme
	@inlinable func foregroundSystemBackground() -> Text {
		foregroundStyle(.systemBackground)
	}
	
	/// > Light Gran for default ColorScheme
	@inlinable func foregroundSecondarySystemBackground() -> Text {
		foregroundStyle(.secondarySystemBackground)
	}
	
	// MARK: > Accent
	
	@inlinable func foregroundAccent() -> Text { foregroundStyle(.tint) }
	
	// MARK: > Common
	
	@inlinable func foregroundWhite() -> Text { foregroundStyle(.white) }
	@inlinable func foregroundBlack() -> Text { foregroundStyle(.black) }
	@inlinable func foregroundPlaceholder() -> Text { foregroundStyle(.placeholderText) }
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
	
	@inlinable
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

// MARK: Fixed width/height

extension View {
	/// Horizontal `fixedSize`
	@inlinable
	public func fixedWidth(_ horizontal: Bool = true) -> some View {
		fixedSize(horizontal: horizontal, vertical: false)
	}
	
	/// Vertical `fixedSize`
	@inlinable
	public func fixedHeight(_ vertical: Bool = true) -> some View {
		fixedSize(horizontal: false, vertical: vertical)
	}
}
