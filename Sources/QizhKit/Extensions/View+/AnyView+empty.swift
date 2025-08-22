//
//  AnyView+empty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 09.05.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension AnyView {
	@MainActor public static let empty = AnyView(EmptyView())
}
