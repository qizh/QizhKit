//
//  HorizontalAlignment+TextAlignment.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 15.04.2024.
//  Copyright © 2024 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension HorizontalAlignment {
	public func asTextAlignment() -> TextAlignment {
		switch self {
		case .leading: 	.leading
		case .center: 	.center
		case .trailing: .trailing
		default: 		.leading
		}
	}
}
