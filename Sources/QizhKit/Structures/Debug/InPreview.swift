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
@available(*, deprecated, renamed: "isInPreviewEnvironment", message: "Use the new more reliable global variable `isInPreviewEnvironment`")
public func isRunningInPreview(_ function: String = #function) -> Bool {
	function.hasPrefix("__preview__")
}

/// Checks the `ProcessInfo`'s environment for `XCODE_RUNNING_FOR_PREVIEWS` value
/// and compares it with `1`
public var isInPreviewEnvironment: Bool {
	ProcessInfo.processInfo.environment["XCODE_RUNNING_FOR_PREVIEWS"] == "1"
}
