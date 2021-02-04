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

public extension UIImage {
	func resized(to size: CGSize) -> UIImage {
		UIGraphicsImageRenderer(size: size).image { _ in
			draw(in: CGRect(origin: .zero, size: size))
		}
	}
	
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

