//
//  QizhKit.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 11.12.2025.
//

import Foundation

#if RESOLVED_HDR_AVAILABLE
let qh2 = true
#else
let qh2 = false
#endif

// MARK: Bundle

extension Bundle {
	public static let qizhKit: Bundle = .module
}
