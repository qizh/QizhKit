//
//  LabelStyles.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.09.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
public struct NavbarLabelStyle: LabelStyle {
	private let iconSide: Side
	private let color: Color?
	
	public init(
		_ color: Color?,
		icon iconSide: Side
	) {
		self.color = color
		self.iconSide = iconSide
	}
	
	public func makeBody(configuration: Configuration) -> some View {
		HStack(spacing: 5) {
			if iconSide.is(.leading) {
				configuration.icon
			}
			
			configuration.title
				.regular(16)
			
			if iconSide.is(.trailing) {
				configuration.icon
			}
		}
		.foregroundColor(color)
	}
	
	public enum Side: EasyCaseComparable {
		case leading
		case trailing
	}
}

@available(iOS 14.0, *)
public extension View {
	@inlinable func labelStyleNavbar(
		_ color: Color?,
		icon iconSide: NavbarLabelStyle.Side
	) -> some View {
		labelStyle(
			NavbarLabelStyle(color, icon: iconSide)
		)
	}
	
	@inlinable func labelStyleIcon() -> some View {
		labelStyle(IconOnlyLabelStyle())
	}
	
	@inlinable func labelStyleTitle() -> some View {
		labelStyle(TitleOnlyLabelStyle())
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
