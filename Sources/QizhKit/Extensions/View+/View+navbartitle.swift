//
//  File.swift
//  
//
//  Created by Serhii Shevchenko on 28.09.2020.
//

import SwiftUI

public extension View {
	@inlinable
	@ViewBuilder
	func navTitle <S: StringProtocol> (
		_ title: S,
		_ displayMode: NavigationBarItem.TitleDisplayMode = .automatic
	) -> some View {
		if #available(iOS 14.0, *) {
			self.navigationTitle(title)
				.navigationBarTitleDisplayMode(displayMode)
		} else {
			navigationBarTitle(Text(title), displayMode: displayMode)
		}
	}
	
	@inlinable
	@ViewBuilder
	func navTitle(
		_ text: Text,
		_ displayMode: NavigationBarItem.TitleDisplayMode = .automatic
	) -> some View {
		if #available(iOS 14.0, *) {
			self.navigationTitle(text)
				.navigationBarTitleDisplayMode(displayMode)
		} else {
			navigationBarTitle(text, displayMode: displayMode)
		}
	}
	
	/*
	@inlinable
	@ViewBuilder
	func navTitle (
		_ displayMode: NavigationBarItem.TitleDisplayMode
	) -> some View {
		if #available(iOS 14.0, *) {
			navigationBarTitleDisplayMode(displayMode)
		} else {
			navigationBarTitle(.empty, displayMode: displayMode)
		}
	}
	*/
}
