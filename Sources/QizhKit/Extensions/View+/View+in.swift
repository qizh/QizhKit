//
//  SwiftUIView.swift
//  
//
//  Created by Serhii Shevchenko on 27.09.2020.
//

import SwiftUI

public extension View {
	@inlinable
	func inNavigationView(
		_ title: String? = nil,
		_ displayMode: NavigationBarItem.TitleDisplayMode = .automatic
	) -> some View {
		NavigationView {
			navTitle(title.orEmpty, displayMode)
		}
	}
}

struct View_in_Previews: PreviewProvider {
	static var previews: some View {
		Group {
			Pixel()
			
			/*
			Text("Hello, World!")
				.inNavigationView("Title")
				.previewDisplayName("in NavigationView")
			*/
		}
	}
}
