//
//  View+navigation.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 12.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

#if canImport(UIKit)
import SwiftUI

public extension View {
	func navigationBarItems <L: View, T: View> (
		 leading: @autoclosure () -> L?,
		trailing: @autoclosure () -> T?
	) -> some View {
		self.apply(when: leading().isSet && trailing().isSet) { view in
				view.navigationBarItems(
					 leading:  leading().forceUnwrapBecauseTested(),
					trailing: trailing().forceUnwrapBecauseTested()
				)
			}
			.apply(when: leading().isSet && trailing().isNotSet) { view in
				view.navigationBarItems(
					leading: leading().forceUnwrapBecauseTested()
				)
			}
			.apply(when: leading().isNotSet && trailing().isSet) { view in
				view.navigationBarItems(
					trailing: trailing().forceUnwrapBecauseTested()
				)
			}
	}
}
#endif
