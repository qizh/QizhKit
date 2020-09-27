//
//  Text+empty.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 31.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension Text: EmptyComparable {
	public static let empty = Text(verbatim: .empty)
}
