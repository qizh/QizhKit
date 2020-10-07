//
//  View+becomeFirstResponder.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Introspect

public struct BecomeFirstResponder: ViewModifier {
	@State private var textField: UITextField?
	private let become: Bool
	private let onBecome: () -> Void
	
	public init(_ become: Bool, onBecome: @escaping () -> Void = {}) {
		self.become = become
		self.onBecome = onBecome
	}
	
	public func body(content: Content) -> some View {
		ZStack(alignment: .top) {
			content
				.introspectTextField { textField in
//					print("Introspected TextField: \(textField)")
					self.textField ??= textField
				}
				.zIndex(20)
				
				if become && textField.isSet {
					Pixel()
						.onAppear(perform: becomeFirstResponder)
						.zIndex(10)
				}
				/*
				.onAppear {
					if become && textField.isSet {
						becomeFirstResponder()
					}
				}
				*/
		}
//			.whenAppear(if: become && textField.isSet, perform: becomeFirstResponder)
			/*
			.apply(when: become && textField.isSet) { view in
				view.onAppear(perform: becomeFirstResponder)
			}
			*/
	}
	
	private func becomeFirstResponder() {
		textField?.becomeFirstResponder()
		onBecome()
	}
	
	/*
	private func tryToBecome(attempt: UInt) {
		if let textField = textField {
			textField.becomeFirstResponder()
			self.onBecome()
		} else if attempt <= 3 {
			execute(in: 100) {
				self.tryToBecome(attempt: attempt + 1)
			}
		}
	}
	*/
}

public extension View {
	func becomeFirstResponder(when condition: Bool) -> some View {
		apply(when: condition) { view in
			view.introspectTextField { field in
				field.becomeFirstResponder()
			}
		}
	}
	
	func becomeFirstResponder<S>(
		when state: Binding<S>,
		  is value: S,
		then unvalue: S
	) -> ModifiedContent<Self, BecomeFirstResponder>
		where S: EasyComparable, S == S.Other
	{
		modifier(
			BecomeFirstResponder(state.wrappedValue.is(value)) {
				execute {
					state.wrappedValue = unvalue
				}
			}
		)
	}
	
	func becomeFirstResponder(in ms: Int) -> some View {
		introspectTextField { field in
			execute(in: ms) {
				field.becomeFirstResponder()
			}
		}
	}
	
	func returnKeyType(_ type: UIReturnKeyType) -> some View {
		introspectTextField { field in
			field.returnKeyType = type
		}
	}
}
