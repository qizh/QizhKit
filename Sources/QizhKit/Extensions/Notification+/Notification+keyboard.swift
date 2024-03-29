//
//  Notification+keyboard.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.01.23.
//  Copyright © 2023 Serhii Shevchenko. All rights reserved.
//

import UIKit

extension Notification {
	public var keyboardFrame: CGRect? {
		#if os(iOS)
		(userInfo?[UIApplication.keyboardFrameEndUserInfoKey] as? CGRect)?
			.intersection(UIScreen.main.bounds)
			.standardized
		#elseif os(visionOS)
		.none
		#endif
	}
}
