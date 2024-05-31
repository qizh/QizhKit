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
	/// Resizing the image fitting into the provided size.
	/// Image size will be smaller or equal to the provided size.
	/// - Parameters:
	///   - size: Target size
	///   - transparent: Keep the image transparency
	/// - Returns: Resized copy of the image
	public func resizedCopyFitting(_ size: CGSize, transparent: Bool = true) -> UIImage {
		self.resizedCopy(to: size, contentMode: .fit, transparent: transparent)
	}
	
	/// Resizing the image filling the provided size.
	/// Image size will be larger or equal to the provided size.
	/// - Parameters:
	///   - size: Target size
	///   - transparent: Keep the image transparency
	/// - Returns: Resized copy of the image
	public func resizedCopyFilling(_ size: CGSize, transparent: Bool = true) -> UIImage {
		self.resizedCopy(to: size, contentMode: .fill, transparent: transparent)
	}
	
	/// Resizing the image keeping aspect ratio
	/// - Parameters:
	///   - size: Target size
	///   - contentMode: Fitting or filling the target size
	///   - transparent: Keep the image transparency
	/// - Returns: Resized copy of the image
	public func resizedCopy(
		to size: CGSize,
		contentMode: ContentMode = .fit,
		transparent: Bool = true
	) -> UIImage {
		let scale: CGFloat = switch contentMode {
			case .fit:  min(size.width / self.size.width, size.height / self.size.height)
			case .fill: max(size.width / self.size.width, size.height / self.size.height)
		}
		
		let scaledSize = self.size.scaled(.both(.factor(scale)))
		
		let renderFormat = UIGraphicsImageRendererFormat()
		renderFormat.opaque = not(transparent)
		
		return UIGraphicsImageRenderer(
			size: scaledSize,
			format: renderFormat
		)
		.image { _ in
			draw(in: CGRect(origin: .zero, size: scaledSize))
		}
	}
	
	/// Resizing the image without keeping the aspect ratio
	/// - Parameter size: Target size
	/// - Returns: Resized copy of the image
	public func resized(to size: CGSize) -> UIImage {
		UIGraphicsImageRenderer(size: size).image { _ in
			draw(in: CGRect(origin: .zero, size: size))
		}
	}
}

extension UIImage {
	/// Keeping aspect ratio
	@available(*, deprecated, renamed: "resizedCopy(to:contentMode:transparent:)", message: "This method doesn't really work")
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

