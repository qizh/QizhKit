//
//  SwiftUIView.swift
//  
//
//  Created by Serhii Shevchenko on 27.09.2020.
//

import SwiftUI

@available(iOS 14.0, *)
public extension View {
	func inNavigationView(
		_ title: String? = nil,
		_ displayMode: NavigationBarItem.TitleDisplayMode = .automatic
	) -> some View {
		NavigationView {
			if let title = title?.nonEmpty {
				self
					.navigationTitle(title)
					.navigationBarTitleDisplayMode(displayMode)
			} else {
				self
			}
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
