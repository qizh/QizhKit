//
//  VisualEffects.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 28.02.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

#if canImport(UIKit)
// MARK: Default Styles

extension UIBlurEffect.Style: WithDefault {
	public static var `default`: UIBlurEffect.Style { .light }
}

extension UIVibrancyEffectStyle: WithDefault {
	public static var `default`: UIVibrancyEffectStyle { .label }
}

// MARK: Auto style

public extension UIBlurEffect.Style {
	static func auto(_ colorScheme: ColorScheme) -> UIBlurEffect.Style {
		colorScheme.is(.dark) ? .dark : .extraLight
	}
}

// MARK: Basic Effects

public struct VisualEffectView: UIViewRepresentable {
	public var effect: UIVisualEffect?
	public func makeUIView(context: Context) -> UIVisualEffectView { UIVisualEffectView() }
	public func updateUIView(_ uiView: UIVisualEffectView, context: Context) { uiView.effect = effect }
}

public struct BlurredBackgroundView: View {
	private let style: UIBlurEffect.Style
	
	public init(style: UIBlurEffect.Style = .default) {
		self.style = style
	}
	
	public var body: some View {
		VisualEffectView(effect: UIBlurEffect(style: style))
	}
}

// MARK: With Vibrancy

struct VibrantOnBlurredBackground: UIViewRepresentable {
	private let contentBuilder: () -> AnyView
	private let blurEffectStyle: UIBlurEffect.Style
	private let vibrancyEffectStyle: UIVibrancyEffectStyle
	
	init<Content: View>(
		blur: UIBlurEffect.Style = .default,
		vibrancy: UIVibrancyEffectStyle = .default,
		@ViewBuilder sourceContentBuilder: @escaping () -> Content
	) {
		self.contentBuilder = {
			AnyView(
				sourceContentBuilder()
					.edgesIgnoringSafeArea(.all)
					.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
			)
		}
		self.blurEffectStyle = blur
		self.vibrancyEffectStyle = vibrancy
	}
	
	var contentVC: UIHostingController<AnyView> {
		UIHostingController(rootView: contentBuilder())
	}
	
	func makeUIView(context: Context) -> UIContainer {
		let container = UIContainer(frame: .zero)
		container.blurEffectStyle = blurEffectStyle
		container.vibrancyEffectStyle = vibrancyEffectStyle
		container.hostingView = contentVC.view
		return container
	}
	
	func updateUIView(_ container: UIContainer, context: Context) {
		container.blurEffectStyle = blurEffectStyle
		container.vibrancyEffectStyle = vibrancyEffectStyle
		container.hostingView = contentVC.view
	}
	
	class UIContainer: UIView {
		let blurView: UIVisualEffectView
		let vibrancyView: UIVisualEffectView
		
		var blurEffectStyle: UIBlurEffect.Style = .default {
			didSet {
				if oldValue == blurEffectStyle { return }
				updateBlurStyle()
			}
		}
		
		var vibrancyEffectStyle: UIVibrancyEffectStyle = .default {
			didSet {
				if oldValue == vibrancyEffectStyle { return }
				updateVibrancyStyle()
			}
		}
		
		var hostingView: UIView? {
			didSet {
				oldValue?.removeFromSuperview()
				if let hostingView = hostingView {
					hostingView.backgroundColor = .clear
					vibrancyView.contentView.addSubview(hostingView)
				}
				setNeedsLayout()
				setNeedsDisplay()
			}
		}
		
		override init(frame: CGRect) {
			self.blurView = UIVisualEffectView(effect: nil)
			self.vibrancyView = UIVisualEffectView(effect: nil)
			
			super.init(frame: frame)
			
			blurView.contentView.addSubview(vibrancyView)
			addSubview(blurView)
			
			updateBlurStyle()
		}
		
		required init?(coder: NSCoder) {
			fatalError("init(coder:) has not been implemented")
		}
		
		override func layoutSubviews() {
			super.layoutSubviews()
			
			let bounds = self.bounds
			blurView.frame = bounds
			vibrancyView.frame = bounds
			hostingView?.frame = bounds
		}
		
		fileprivate func updateBlurStyle() {
			blurView.effect = UIBlurEffect(style: blurEffectStyle)
			updateVibrancyStyle()
		}
		
		fileprivate func updateVibrancyStyle() {
			guard let blurEffect = blurView.effect as? UIBlurEffect else { return }
			vibrancyView.effect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancyEffectStyle)
		}
	}
}

/*
struct VibrantOnBlurredBackground<Content>: UIViewRepresentable where Content: View {
	private var blurStyle: UIBlurEffect.Style = .default
	private var vibrancyStyle: UIVibrancyEffectStyle = .default
	private var content: Content
	private var contentVC: UIHostingController<Content>
	
	init(
		blurStyle: UIBlurEffect.Style = .default,
		vibrancyStyle: UIVibrancyEffectStyle = .default,
		@ViewBuilder content: () -> Content
	) {
		self.blurStyle = blurStyle
		self.content = content()
		self.contentVC = UIHostingController(rootView: self.content)
	}
	
	func makeUIView(context: Context) -> UIVisualEffectView {
		let blurEffect = UIBlurEffect(style: blurStyle)
		let blurEffectView = UIVisualEffectView(effect: blurEffect)
		
//		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect, style: vibrancyStyle)
		let vibrancyEffect = UIVibrancyEffect(blurEffect: blurEffect)
		let vibrancyEffectView = UIVisualEffectView(effect: vibrancyEffect)
		
//		let contentView = contentVC.view!
		let contentView = UILabel()
		contentView.text = "Test"
//		contentView.translatesAutoresizingMaskIntoConstraints = false
		
		vibrancyEffectView.contentView.addSubview(contentView)
		blurEffectView.contentView.addSubview(vibrancyEffectView)
		
//		contentView.frame = vibrancyEffectView.contentView.bounds
		
//		contentView.topAnchor.constraint(equalTo: vibrancyEffectView.contentView.topAnchor).isActive = true
//		contentView.leftAnchor.constraint(equalTo: vibrancyEffectView.contentView.leftAnchor).isActive = true
//		contentView.bottomAnchor.constraint(equalTo: vibrancyEffectView.contentView.bottomAnchor).isActive = true
//		contentView.rightAnchor.constraint(equalTo: vibrancyEffectView.contentView.rightAnchor).isActive = true
//		vibrancyEffectView.contentView.setNeedsLayout()
		
		return blurEffectView
	}
	func updateUIView(_ uiView: UIVisualEffectView, context: Context) {
//		guard
//			let blurEffect = uiView.effect as? UIBlurEffect,
//			let vibrancyEffectView = uiView.contentView.subviews.first as? UIVisualEffectView,
//			let vibrancyEffect = vibrancyEffectView.effect as? UIVibrancyEffect
//		else { return }
	}
}
*/

// TODO: Implement multiple vibrant layers 

// MARK: View extensions

public extension View {
	@inlinable
	func onBlurredBackground(style: UIBlurEffect.Style = .default) -> some View {
		background(BlurredBackgroundView(style: style))
	}
	
	func vibrantOnBlurredBackground(
		blur: UIBlurEffect.Style = .default,
		vibrancy: UIVibrancyEffectStyle = .default
	) -> some View {
		VibrantOnBlurredBackground(blur: blur, vibrancy: vibrancy) { self }
	}
}

// MARK: Previews

#if DEBUG
struct VisualEffects_Previews: PreviewProvider {
    static var previews: some View {
        EmptyView()
    }
}
#endif
#endif
