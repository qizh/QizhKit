//
//  View+toolbar.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.05.2022.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	@available(iOS 14.0, *)
	@inlinable
	public func hideInlineNavigationBarTitle(hide: Bool = true) -> some View {
		toolbar {
			ToolbarItem(placement: .principal) {
				if hide {
					Text.empty
				}
			}
		}
	}
	
	/// An iOS 14 only hack to make `ToolbarItem` treat the `Label` or `Text` as `View`
	@available(iOS 14.0, *)
	@inlinable
	public func asToolbarView() -> some View {
		HStack(spacing: 0) {
			self
			if #unavailable(iOS 15) {
				Text.empty
			}
		}
		
		// add(.trailing, spacing: .zero) { Text.empty }
	}
}
