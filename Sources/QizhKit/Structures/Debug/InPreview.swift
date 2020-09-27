//
//  InPreview.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 30.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

/// Call it with no parameters to find out if the place you called it is running in a preview
/// - Parameter function: A `#function` value
public func isRunningInPreview(_ function: String = #function) -> Bool {
	function.hasPrefix("__preview__")
}

/*
public extension String {
	@inlinable var isRunningInPreview: Bool {
		hasPrefix("__preview__")
	}
}
*/
