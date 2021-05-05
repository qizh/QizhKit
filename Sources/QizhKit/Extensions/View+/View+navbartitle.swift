//
//  View+navbartitle.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.09.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension View {
	@ViewBuilder
	func navTitle <S: StringProtocol> (
		_ title: S,
		_ displayMode: NavigationBarItem.TitleDisplayMode = .automatic
	) -> some View {
		if #available(iOS 14.0, *) {
			self.navigationTitle(title)
				.navigationBarTitleDisplayMode(displayMode)
		} else {
			self.navigationBarTitle(Text(title), displayMode: displayMode)
		}
	}
	
	@ViewBuilder
	func navTitle(
		_ text: Text,
		_ displayMode: NavigationBarItem.TitleDisplayMode = .automatic
	) -> some View {
		if #available(iOS 14.0, *) {
			self.navigationTitle(text)
				.navigationBarTitleDisplayMode(displayMode)
		} else {
			self.navigationBarTitle(text, displayMode: displayMode)
		}
	}
}
