//
//  View+onOpenURL.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.09.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(iOS 15.0, *)
extension View {
	public func onInterceptOpenURL(
		perform handler: @escaping (URL) -> OpenURLAction.Result
	) -> some View {
		self.environment(\.openURL, OpenURLAction(handler: handler))
	}
}
