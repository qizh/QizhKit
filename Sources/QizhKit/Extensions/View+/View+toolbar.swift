//
//  View+toolbar.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 06.05.2022.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	/// Adds `.principal` toolabar item with empty ``Text``
	@inlinable public func hideInlineNavigationBarTitle(hide: Bool = true) -> some View {
		toolbar {
			ToolbarItem(placement: .principal) {
				if hide {
					Text(String.empty)
				}
			}
		}
	}
	
	/// An iOS 14 only hack to make `ToolbarItem` treat the `Label` or `Text` as `View` – wraps it in an `HStack` with emtpy `Text`
	@ViewBuilder
	public func asToolbarView() -> some View {
		if #available(iOS 15, *) {
			self
		} else {
			HStack(spacing: 0) {
				self
				Text(String.empty)
			}
		}
	}
}
