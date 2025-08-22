//
//  Rotated.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.03.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Old

public struct Rotated <Wrapped: View>: View {
	private let wrapped: Wrapped
	private let angle: Angle

	@State private var size: CGSize = .zero
	
	public init(_ view: Wrapped, angle: Angle = .degrees(-90)) {
		self.wrapped = view
		self.angle = angle
	}
	
	public var body: some View {
		wrapped
			.fixedSize()
			.background {
				GeometryReader { geometry -> Color in
					executeAssign(geometry.size, to: $size)
					return Color.clear
				}
			}
			.rotationEffect(angle)
			.size(rotatedFrame.size)
	}
	
	private var rotatedFrame: CGRect {
		CGRect(.zero, size)
			.offsetBy(
				dx: -size.width.half,
				dy: -size.height.half
			)
			.applying(
				CGAffineTransform(
					rotationAngle: CGFloat(angle.radians)
				)
			)
			.integral
	}
}

public extension View {
	@inlinable
	func rotated(_ angle: Angle) -> some View {
		Rotated(self, angle: angle)
	}
}

// MARK: - Rotated View Modifier

public struct FullscreenRotationModifier: ViewModifier {
	private let angle: Angle
	private let toolbarIsHidden: Bool
	
	@State private var originalSize: CGSize = .zero
	
	@Environment(\.safeFrameInsets) private var safeAreaInsets
	
	/// Rotates fullscreen object like video player
	/// - Parameters:
	///   - angle: `Angle` to rotate
	///   - toolbarIsHidden: Whether or not you hide the top and bottom
	///   	bars when video is playing. It will affect how the content
	///   	is vertically centered.
	public init(angle: Angle, toolbarIsHidden: Bool) {
		self.angle = angle
		self.toolbarIsHidden = toolbarIsHidden
	}
	
	public func body(content: Content) -> some View {
		GeometryReader { geometry in
			content
				.background(
					GeometryReader { innerGeometry in
						Color.clear
							.onAppear {
								originalSize = innerGeometry.size
							}
					}
				)
				.apply(when: originalSize.isNotZero) { view in
					let rotatedSize = rotatedSize(
						for: geometry.size,
						insets: geometry.safeAreaInsets
					)
					
					view
						.frame(
							width: rotatedSize.width,
							height: rotatedSize.height
						)
						.rotationEffect(angle)
						.position(
							x: geometry.size.width / 2,
							y: (geometry.size.height
								+ (toolbarIsHidden
								   ? geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom
								   : 0)
							    ) / 2
						)
				}
				.ignoresSafeArea(.container, edges: toolbarIsHidden ? .all : [])
		}
	}
	
	private func rotatedSize(for size: CGSize, insets: EdgeInsets) -> CGSize {
		let availableWidth = size.width
		let availableHeight = size.height
		
		let radians = CGFloat(angle.radians)
		
		let newWidth = abs(availableWidth * cos(radians)) + abs(availableHeight * sin(radians))
		let newHeight = abs(availableHeight * cos(radians)) + abs(availableWidth * sin(radians))
		
		return CGSize(width: newWidth, height: newHeight)
	}
}

extension View {
	/// Rotates fullscreen object like video player
	/// - Parameters:
	///   - angle: `Angle` to rotate
	///   - toolbarIsHidden: Whether or not you hide the top and bottom
	///   	bars when video is playing. It will affect how the content
	///   	is vertically centered.
	@inlinable public func fullscreenRotation(
		to angle: Angle,
		toolbarIsHidden: Bool
	) -> some View {
		modifier(
			FullscreenRotationModifier(
				angle: angle,
				toolbarIsHidden: toolbarIsHidden
			)
		)
	}
}
