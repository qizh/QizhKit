//
//  TextField+select.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.11.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	public func selectAllOnTextFieldFocus() -> some View {
		onReceive(
			NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification)
		) { notification in
			guard let textField = notification.object as? UITextField else { return }
			textField.selectedTextRange = textField.textRange(
				from: textField.beginningOfDocument,
				to: textField.endOfDocument
			)
		}

	}
}
