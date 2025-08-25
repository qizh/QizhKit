//
//  UIImage+alpha.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.06.2022.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

#if canImport(UIKit)
import UIKit

extension UIImage {
	public func isTransparent() -> Bool {
		guard let alpha = self.cgImage?.alphaInfo else { return false }
		return alpha == .first
			|| alpha == .last
			|| alpha == .premultipliedFirst
			|| alpha == .premultipliedLast
	}
}
#endif
