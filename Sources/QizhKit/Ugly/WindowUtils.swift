//
//  WindowUtils.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 25.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import UIKit

public struct WindowUtils {
	public static private(set) var originalWindow: UIWindow?
	public static func setOriginalWindow(_ window: UIWindow) {
		originalWindow = window
	}
	
	// @available(iOSApplicationExtension, unavailable)
	public static var windowScene: UIWindowScene? {
		UIApplication.shared
			.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.first as? UIWindowScene
	}
	
	// @available(iOSApplicationExtension, unavailable)
	public static var keyWindow: UIWindow? {
		UIApplication.shared.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.compactMap { $0 as? UIWindowScene }
			.first?
			.windows
			.filter { $0.isKeyWindow}
			.first
	}
	
	public static var rootViewController: UIViewController? {
		originalWindow?.rootViewController
	}
	
	public static var currentWindow: UIWindow? {
		originalWindow
		// keyWindow ?? originalWindow
	}
}

@inlinable public func endEditing() {
	endEditing(force: false)
}

@inlinable public func endEditing(force: Bool) {
	WindowUtils.originalWindow?.endEditing(force)
}

public struct SafeFrame {
	public static var currentInsets: UIEdgeInsets {
		WindowUtils.currentWindow?.safeAreaInsets ?? .zero
	}
}
