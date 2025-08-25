//
//  TextField+select.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 03.11.22.
//  Copyright © 2022 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine

#if canImport(UIKit)
extension View {
	@available(*, deprecated, renamed: "selectAllOnTextEditingBegin", message: "This modifier only affects TextField, use another one that affects both TextField and TextEditor")
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
	
	/// On `textDidBeginEditingNotification` notification will change text input's `selectedTextRange` to the whole document range
	public func selectAllOnTextEditingBegin() -> some View {
		onReceive(
			Publishers.Merge(
				NotificationCenter.default.publisher(for: UITextField.textDidBeginEditingNotification),
				NotificationCenter.default.publisher(for: UITextView.textDidBeginEditingNotification)
			)
		) { notification in
			guard let field = notification.object as? UITextInput else { return }
			field.selectedTextRange = field.textRange(
				from: field.beginningOfDocument,
				to: field.endOfDocument
			)
		}
	}
}
#endif
