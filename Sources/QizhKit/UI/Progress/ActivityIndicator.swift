//
//  ActivityIndicator.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 11.09.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Swift
import SwiftUI
import UIKit

public struct ActivityIndicator: UIViewRepresentable {
	private let style: UIActivityIndicatorView.Style
	private let color: UIColor?
	
	private var isAnimated: Bool = true
	
	public init(style: UIActivityIndicatorView.Style = .large, color: UIColor? = nil) {
		self.style = style
		self.color = color
	}
	
	public func makeUIView(context: Context) -> UIActivityIndicatorView {
		let view = UIActivityIndicatorView(style: style)
		view.color = color
		view.setNeedsLayout()
		return view
	}
	
	public func updateUIView(_ uiView: UIActivityIndicatorView, context: Context) {
		uiView.startAnimating()
		isAnimated ? uiView.startAnimating() : uiView.stopAnimating()
	}

	public func animated(_ isAnimated: Bool) -> ActivityIndicator {
		var result = self
		result.isAnimated = isAnimated
		return result
	}
}
