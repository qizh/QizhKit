//
//  WindowUtils.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 25.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import UIKit

public struct WindowUtils {
	@MainActor private static var manuallyAssignedWindow: UIWindow?
	@MainActor public static func setOriginalWindow(_ window: UIWindow) {
		manuallyAssignedWindow = window
	}
	
	// @available(iOSApplicationExtension, unavailable)
	@MainActor public static var windowScene: UIWindowScene? {
		UIApplication.shared
			.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.first as? UIWindowScene
	}
	
	// @available(iOSApplicationExtension, unavailable)
	@MainActor public static var keyWindow: UIWindow? {
		UIApplication.shared.connectedScenes
			.filter { $0.activationState == .foregroundActive }
			.compactMap { $0 as? UIWindowScene }
			.flatMap(\.windows)
			.first(where: \.isKeyWindow)
			/*
			.first?
			.windows
			.filter { $0.isKeyWindow}
			.first
			*/
	}
	
	@MainActor public static var rootViewController: UIViewController? {
		currentWindow?.rootViewController
	}
	
	@MainActor public static var originalWindow: UIWindow? {
		manuallyAssignedWindow ?? keyWindow
	}
	
	@MainActor public static var currentWindow: UIWindow? {
		manuallyAssignedWindow ?? keyWindow
		// keyWindow ?? originalWindow
	}
	
	@MainActor public static func topViewController(
		_ viewController: UIViewController? = .none
	) -> UIViewController? {
		let vc = viewController
			?? keyWindow?.rootViewController
		
		if let nc = vc as? UINavigationController {
			return topViewController(nc.topViewController)
		} else if let tc = vc as? UITabBarController {
			return tc.presentedViewController.isSet
				? topViewController(tc.presentedViewController)
				: topViewController(tc.selectedViewController)
		} else if let pc = vc?.presentedViewController {
			return topViewController(pc)
		}
		return vc
	}
}

@inlinable @MainActor public func endEditing() {
	endEditing(force: false)
}

@inlinable @MainActor public func endEditing(force: Bool) {
	WindowUtils.currentWindow?.endEditing(force)
}

public struct SafeFrame {
	@MainActor public static var currentInsets: UIEdgeInsets {
		WindowUtils.currentWindow?.safeAreaInsets ?? .zero
	}
}
