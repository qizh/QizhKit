//
//  EmptyScreen.swift
//  
//
//  Created by Serhii Shevchenko on 07.10.2020.
//

import SwiftUI

public struct EmptyScreen: View {
	private let title: String
	
	public init(_ title: String) {
		self.title = title
	}
	
	public var body: some View {
        EmptyView()
			.navTitle(title, .large)
    }
}

struct EmptyScreen_Previews: PreviewProvider {
    static var previews: some View {
		EmptyScreen("Test")
    }
}
