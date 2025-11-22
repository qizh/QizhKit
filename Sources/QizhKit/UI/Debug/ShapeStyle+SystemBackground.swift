// ShapeStyle+SystemBackground.swift
// Added to provide a cross-platform `.systemBackground` ShapeStyle shorthand

import SwiftUI

#if canImport(UIKit)
import UIKit
#endif

#if canImport(AppKit)
import AppKit
#endif

public extension ShapeStyle {
    /// A platform-adaptive system background style usable where a `ShapeStyle` is expected.
    ///
    /// Usage: `.background(.systemBackground, in: shape)`
    static var systemBackground: Color {
        #if os(iOS) || targetEnvironment(macCatalyst) || os(tvOS) || os(watchOS)
        return Color(uiColor: .systemBackground)
        #elseif os(macOS)
        return Color(nsColor: .windowBackgroundColor)
        #else
        return Color(.white)
        #endif
    }
}