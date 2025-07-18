//
//  Layout+shortcuts.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 18.07.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

public import Foundation

extension Layout where Self == VStackLayout {
	@inlinable public static func vStack(
		alignment: HorizontalAlignment = .center,
		spacing: CGFloat? = .none
	) -> Self {
		VStackLayout(alignment: alignment, spacing: spacing)
	}
}

extension Layout where Self == HStackLayout {
	@inlinable public static func hStack(
		alignment: VerticalAlignment = .center,
		spacing: CGFloat? = .none
	) -> Self {
		HStackLayout(alignment: alignment, spacing: spacing)
	}
}
