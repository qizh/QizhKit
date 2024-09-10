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

public struct RotationModifier: ViewModifier {
	private let angle: Angle
	private let toolbarIsHidden: Bool
	
	@State private var originalSize: CGSize = .zero
	// @State private var size: CGSize = .zero
	
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
		/// v4 chat
		
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
							y: (geometry.size.height + (toolbarIsHidden ? geometry.safeAreaInsets.top + geometry.safeAreaInsets.bottom : 0)) / 2
						)
					/*
					view
						.frame(width: rotatedSize(for: geometry.size, insets: geometry.safeAreaInsets).width,
							   height: rotatedSize(for: geometry.size, insets: geometry.safeAreaInsets).height)
						.rotationEffect(angle)
						.position(
							x: geometry.size.width / 2,
							y: geometry.size.height / 2 + geometry.safeAreaInsets.top - NavigationBarDimension.height
						)
					*/
				}
				.ignoresSafeArea(.container, edges: toolbarIsHidden ? .all : [])
				// .edgesIgnoringSafeArea(.vertical)
		}
		// .ignoresSafeArea(.all, edges: .horizontal)
		// .ignoresSafeArea(.container, edges: .vertical)
		
		/// v3 chat --- Good
		
		/*
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
					view
						.frame(width: rotatedSize(for: originalSize).width, height: rotatedSize(for: originalSize).height)
						.rotationEffect(angle)
						.position(x: geometry.size.width / 2, y: geometry.size.height / 2)
				}
		}
		*/

		
		/// v2 from ChatGPT
		/*
		GeometryReader { geometry in
			content
				.frame(width: geometry.size.width, height: geometry.size.height)
				.rotationEffect(angle)
				.frame(width: rotatedSize(for: geometry.size).width,
					   height: rotatedSize(for: geometry.size).height)
				.offset(x: offset(for: geometry.size).width, y: offset(for: geometry.size).height)
		}
		*/
		
		/// v1 from ChatGPT
		/*
		content
			.background(
				GeometryReader { geometry in
					Color.clear
						.onAppear {
							size = geometry.size
						}
				}
			)
			.apply(when: size.isNotZero) { view in
				view
					.frame(width: rotatedSize().width, height: rotatedSize().height)
					.rotationEffect(angle)
			}
		*/
		
		/*
		content
			.background {
				GeometryReader { geometry -> Color in
					Task { @MainActor in
						self.size = geometry.size
					}
					// executeAssign(geometry.size, to: $size)
					return Color.clear
				}
			}
			.rotationEffect(angle)
			.size(rotatedFrame(by: size)?.size)
		*/

		/*
		GeometryReader { geometry in
			let localFrame = geometry.frame(in: .local)
			let frame1 = rotatedFrame(by: geometry.size)
			let frame2 = rotatedFrame(from: localFrame)
			
			content
				.overlay {
					VStack.LabeledViews {
						// angle.degrees.s0.labeledView(label: "angle")
						localFrame.labeledView(label: "geometry")
						frame1.labeledView(label: "frame 1")
						frame2.labeledView(label: "frame 2")
					}
				}
				.size(frame1.size)
				.rotationEffect(angle)
				// .offset(x: frame1.origin.x, y: frame1.origin.y)
		}
		*/
		
		/*
		content
			.fixedSize()
			.background {
				GeometryReader { geometry -> Color in
					executeAssign(geometry.size, to: $size)
					return Color.clear
				}
			}
			.rotationEffect(angle)
			.size(rotatedFrame.size)
		*/
	}
	
	/*
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
	*/
	
	/// v4.1 chat (edited)
	
	private func rotatedSize(for size: CGSize, insets: EdgeInsets) -> CGSize {
		let availableWidth = size.width
		let availableHeight = size.height
		
		let radians = CGFloat(angle.radians)
		
		// Calculate the rotated size while respecting the available size within safe area

		/*
		let newWidth: CGFloat
		let newHeight: CGFloat
		
		if angle == .degrees(90) || angle == .degrees(-90) {
			newWidth = abs(availableWidth * cos(radians)) + abs(availableHeight * sin(radians)) - insets.top - insets.bottom
			newHeight = abs(availableHeight * cos(radians)) + abs(availableWidth * sin(radians)) - insets.leading - insets.trailing
		} else {
			newWidth = abs(availableWidth * cos(radians)) + abs(availableHeight * sin(radians)) - insets.leading - insets.trailing
			newHeight = abs(availableHeight * cos(radians)) + abs(availableWidth * sin(radians)) - insets.top - insets.bottom
		}
		*/

		let newWidth = abs(availableWidth * cos(radians)) + abs(availableHeight * sin(radians))
		let newHeight = abs(availableHeight * cos(radians)) + abs(availableWidth * sin(radians))
		
		return CGSize(width: newWidth, height: newHeight)
	}
	
	/// v4 chat --- Good
	
	/*
	private func rotatedSize(for size: CGSize, insets: EdgeInsets) -> CGSize {
		let availableWidth = size.width - insets.leading - insets.trailing
		let availableHeight = size.height - insets.top - insets.bottom
		let radians = CGFloat(angle.radians)
		
		// Calculate the rotated size while respecting the available size within safe area
		let newWidth = abs(availableWidth * cos(radians)) + abs(availableHeight * sin(radians))
		let newHeight = abs(availableHeight * cos(radians)) + abs(availableWidth * sin(radians))
		
		return CGSize(width: newWidth, height: newHeight)
	}
	*/
	
	/// v3 chat --- Good
	
	/*
	private func rotatedSize(for size: CGSize) -> CGSize {
		let radians = CGFloat(angle.radians)
		let width = size.width
		let height = size.height
		
		let newWidth = abs(width * cos(radians)) + abs(height * sin(radians))
		let newHeight = abs(height * cos(radians)) + abs(width * sin(radians))
		
		return CGSize(width: newWidth, height: newHeight)
	}
	*/
	
	/// v2 from ChatGPT
	/*
	private func rotatedSize(for size: CGSize) -> CGSize {
		let radians = CGFloat(angle.radians)
		let width = size.width
		let height = size.height
		
		let newWidth = abs(width * cos(radians)) + abs(height * sin(radians))
		let newHeight = abs(height * cos(radians)) + abs(width * sin(radians))
		
		return CGSize(width: newWidth, height: newHeight)
	}
	
	private func offset(for size: CGSize) -> CGSize {
		let radians = CGFloat(angle.radians)
		let width = size.width
		let height = size.height
		
		let newWidth = abs(width * cos(radians)) + abs(height * sin(radians))
		let newHeight = abs(height * cos(radians)) + abs(width * sin(radians))
		
		// Calculate the offset to center the rotated view within the available space
		let offsetX = (width - newWidth) / 2
		let offsetY = (height - newHeight) / 2
		
		return CGSize(width: offsetX, height: offsetY)
	}
	*/
	
	/// v1 from ChatGPT
	/*
	private func rotatedSize() -> CGSize {
		let radians = CGFloat(angle.radians)
		let width = size.width
		let height = size.height
		
		let newWidth = abs(width * cos(radians)) + abs(height * sin(radians))
		let newHeight = abs(height * cos(radians)) + abs(width * sin(radians))
		
		return CGSize(width: newWidth, height: newHeight)
	}
	*/
	
	private func rotatedFrame(by size: CGSize) -> CGRect {
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
	
	private func rotatedFrame(from frame: CGRect) -> CGRect {
		frame
			.offsetBy(
				dx: -frame.size.width.half,
				dy: -frame.size.height.half
			)
			.applying(
				CGAffineTransform(
					rotationAngle: CGFloat(angle.radians)
				)
			)
			.integral
	}

}

extension View {
	/// Rotates fullscreen object like video player
	/// - Parameters:
	///   - angle: `Angle` to rotate
	///   - toolbarIsHidden: Whether or not you hide the top and bottom
	///   	bars when video is playing. It will affect how the content
	///   	is vertically centered.
	@inlinable public func sizeAffectingRotation(
		to angle: Angle,
		toolbarIsHidden: Bool
	) -> some View {
		self.modifier(RotationModifier(angle: angle, toolbarIsHidden: toolbarIsHidden))
	}
}
