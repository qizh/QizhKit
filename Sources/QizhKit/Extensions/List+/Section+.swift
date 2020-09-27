//
//  Section+empty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public extension Section where Parent == EmptyView, Content == EmptyView, Footer == EmptyView {
	@inlinable static var empty: Section<EmptyView, EmptyView, EmptyView> {
		Section(content: EmptyView.init)
	}
}

public extension View {
	@inlinable func inSection() -> Section<EmptyView, Self, EmptyView> {
		Section { self }
	}
}
