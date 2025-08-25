//
//  Animation.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 22.02.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

#if canImport(UIKit)
import SwiftUI

/// Honors `UIAccessibility.isReduceMotionEnabled` by only animating when allowed
@MainActor public func withEnabledAnimation<Result>(
	_ animation: Animation? = .default,
	_ body: () throws -> Result
) rethrows -> Result {
	if UIAccessibility.isReduceMotionEnabled {
		try body()
	} else {
		try withAnimation(animation, body)
	}
}
#endif
