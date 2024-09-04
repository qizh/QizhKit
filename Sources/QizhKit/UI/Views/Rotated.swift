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

// MARK: Rotated View Modifier

public struct RotationModifier: ViewModifier {
	private let angle: Angle
	
	@State private var size: CGSize = .zero
	
	public init(angle: Angle) {
		self.angle = angle
	}
	
	public func body(content: Content) -> some View {
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

public extension View {
	@inlinable
	func sizeAffectingRotation(to angle: Angle) -> some View {
		self.modifier(RotationModifier(angle: angle))
	}
}

