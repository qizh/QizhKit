//
//  LabelStyles.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.09.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

public import SwiftUI
import QizhMacroKit

public struct NavbarLabelStyle: LabelStyle {
	private let iconSide: Side
	private let foregroundStyle: AnyShapeStyle?
	private let customSpacing: CGFloat?
	
	@ScaledMetric(relativeTo: .callout) fileprivate var defaultSpacing: CGFloat = 6
	
	@ScaledMetric(relativeTo: .body) fileprivate var heightSmall: CGFloat = 24
	@ScaledMetric(relativeTo: .body) fileprivate var heightMedium: CGFloat = 30
	@ScaledMetric(relativeTo: .body) fileprivate var heightLarge: CGFloat = 40
	
	@Environment(\.font) fileprivate var font
	@Environment(\.imageScale) fileprivate var imageScale
	
	public init(
		style foregroundStyle: (some ShapeStyle)?,
		icon iconSide: Side,
		spacing customSpacing: CGFloat? = .none
	) {
		self.foregroundStyle = foregroundStyle?.asAnyShapeStyle
		self.iconSide = iconSide
		self.customSpacing = customSpacing
	}
	
	public init(
		icon iconSide: Side,
		spacing customSpacing: CGFloat? = .none
	) {
		self.foregroundStyle = .none
		self.iconSide = iconSide
		self.customSpacing = customSpacing
	}
	
	@available(*, deprecated, renamed: "init(style:icon:)", message: "Switch to the updated initializer where you can provide ShapeStyle instead of just Color.")
	@inlinable public init(
		_ color: Color?,
		icon iconSide: Side,
		spacing customSpacing: CGFloat? = .none
	) {
		self.init(style: color, icon: iconSide, spacing: customSpacing)
	}
	
	public func makeBody(configuration: Configuration) -> some View {
		HStack(spacing: spacing) {
			if iconSide.isLeading {
				configuration.icon
					.scaledToFit()
					.square(imageHeight, .center)
			}
			
			configuration.title
				.font(font ?? .callout.weight(.regular))
			
			if iconSide.isTrailing {
				configuration.icon
					.scaledToFit()
					.square(imageHeight, .center)
			}
		}
		.foregroundStyle(foregroundStyle ?? ForegroundStyle.foreground.asAnyShapeStyle)
	}
	
	fileprivate var spacing: CGFloat {
		customSpacing ?? defaultSpacing
	}
	
	fileprivate var imageHeight: CGFloat {
		switch imageScale {
		case .small: 		heightSmall
		case .medium: 		heightMedium
		case .large: 		heightLarge
		@unknown default: 	heightLarge
		}
	}
	
	@IsCase
	public enum Side: Hashable, Sendable {
		case leading
		case trailing
	}
}

extension LabelStyle where Self == NavbarLabelStyle {
	@inlinable public static func navbar(
		style foregroundStyle: (some ShapeStyle)?,
		icon iconSide: NavbarLabelStyle.Side,
		spacing customSpacing: CGFloat? = .none
	) -> Self {
		NavbarLabelStyle(
			style: foregroundStyle,
			icon: iconSide,
			spacing: customSpacing
		)
	}
	
	@inlinable public static func navbar(
		icon iconSide: NavbarLabelStyle.Side,
		spacing customSpacing: CGFloat? = .none
	) -> Self {
		NavbarLabelStyle(
			icon: iconSide,
			spacing: customSpacing
		)
	}
}

extension View {
	@available(*, deprecated, renamed: "labelStyle(_:)", message: "Switch to the `LabelStyle.navbar(color:icon:)` static function.")
	@inlinable public func labelStyleNavbar(
		_ color: Color? = .none,
		icon iconSide: NavbarLabelStyle.Side,
		spacing customSpacing: CGFloat? = .none
	) -> some View {
		labelStyle(
			NavbarLabelStyle(color, icon: iconSide, spacing: customSpacing)
		)
	}
	
	@available(*, deprecated, renamed: "labelStyle(_:)", message: "Switch to the `LabelStyle.iconOnly` static property.")
	@inlinable public func labelStyleIcon() -> some View {
		labelStyle(.iconOnly)
	}
	
	@available(*, deprecated, renamed: "labelStyle(_:)", message: "Switch to the `LabelStyle.titleOnly` static property.")
	@inlinable public func labelStyleTitle() -> some View {
		labelStyle(.titleOnly)
	}
}

/*
extension UIView {
	var image: Image {
		Image(uiImage: renderedImage)
	}
	
	var renderedImage: UIImage {
		UIGraphicsImageRenderer(size: bounds.size).image { context in
			self.layer.render(in: context.cgContext)
		}
	}
	
	func renderedImage(size: CGSize) -> UIImage {
		UIGraphicsImageRenderer(size: size).image { context in
			self.layer.render(in: context.cgContext)
		}
	}
}

extension View {
	func renderedImage() -> Image {
		let uiview = UIHostingController(rootView: self).view!
		uiview.sizeToFit()
		return uiview.image
	}
	
/*
	func renderedImageOriginal(size: CGSize) -> UIImage {
		let center = CGPoint(
			x: (UIScreen.main.bounds.width - size.width) / 2,
			y: (UIScreen.main.bounds.height - size.height) / 2
		)
		let window = UIWindow(frame: CGRect(origin: center, size: size))
		let hosting = UIHostingController(rootView: self)
		hosting.view.frame = window.frame
//		hosting.view.backgroundColor = .white /// For testing
		hosting.view.backgroundColor = .clear
		window.rootViewController = hosting
		window.makeKeyAndVisible()
		return hosting.view.renderedImage
	}
	func renderedImage(size: CGSize) -> UIImage {
		let window = UIWindow(frame: CGRect(origin: .zero, size: size))
		let hosting = UIHostingController(
			rootView: self
				.frame(width: size.width, height: size.height)
				.offset(x: 0, y: window.safeAreaInsets.top == 20 ? -10 : -22) /// Offset is somehow related to a Safe Area but I can't figure out a connection, so I just use two magic numbers here.
			
//				.offset(x: 0, y: 10 - window.safeAreaInsets.top)
//				.offset(x: 0, y: -22) /// Magic number, works for iPhone X family only
		)
		hosting.view.frame = CGRect(origin: .zero, size: size)
//		hosting.view.backgroundColor = .green /// For testing
		hosting.view.backgroundColor = .clear
		window.rootViewController = hosting
		window.makeKeyAndVisible()
		return hosting.view.renderedImage
	}
*/
}
*/
