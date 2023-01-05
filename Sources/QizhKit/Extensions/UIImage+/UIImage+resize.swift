//
//  UIImage+resize.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 21.01.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import UIKit

public extension Image {
	init(
		systemName: String,
		pointSize: CGFloat = 16,
		weight: UIImage.SymbolWeight = .unspecified,
		scale: UIImage.SymbolScale = .default,
		tint: UIColor? = .none
	) {
		var uiImage = UIImage(
			systemName: systemName,
			pointSize: pointSize,
			weight: weight,
			scale: scale
		) ?? UIImage(
			systemName: "questionmark.square.dashed",
			pointSize: pointSize,
			weight: weight,
			scale: scale
		)
		.forceUnwrapBecauseCreated()
		
		if let tint = tint {
			uiImage = uiImage.withTintColor(tint, renderingMode: .alwaysTemplate)
		}
		
		self.init(uiImage: uiImage)
	}
}

// MARK: Resize

extension UIImage {
	/// Keeping aspect ratio
	public func resized(
		to size: CGSize,
		contentMode: ContentMode = .fit,
		opaque: Bool
	) -> UIImage {
		let scale: CGFloat
		switch contentMode {
		case .fit:  scale = min(size.width / self.size.width, size.height / self.size.height)
		case .fill: scale = max(size.width / self.size.width, size.height / self.size.height)
		}
		
		let renderFormat = UIGraphicsImageRendererFormat.default()
		renderFormat.opaque = opaque
		renderFormat.scale = scale
		
		let renderer = UIGraphicsImageRenderer(size: self.size, format: renderFormat)
		let redrawnImage = renderer.image { context in
			self.draw(in: CGRect(origin: .zero, size: self.size))
		}
		return redrawnImage
	}
	
	/// Can change aspect ratio
	public func resized(to size: CGSize) -> UIImage {
		UIGraphicsImageRenderer(size: size).image { _ in
			draw(in: CGRect(origin: .zero, size: size))
		}
	}
}

// MARK: Symbol Configuration

public extension UIImage {
	@inlinable
	convenience init?(
		systemName name: String,
		symbolConfiguration: UIImage.SymbolConfiguration
	) {
		self.init(systemName: name, withConfiguration: symbolConfiguration)
	}
	
	@inlinable
	convenience init?(
		systemName name: String,
		pointSize: CGFloat,
		weight: UIImage.SymbolWeight = .unspecified,
		scale: UIImage.SymbolScale = .default
	) {
		self.init(
			systemName: name,
			symbolConfiguration: .init(
				pointSize: pointSize,
				weight: weight,
				scale: scale
			)
		)
	}
}

