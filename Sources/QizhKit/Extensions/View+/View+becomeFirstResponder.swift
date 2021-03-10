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
	private let msDelay: Int
	private let onBecome: (() -> Void)?
	
	public init(
		_ become: Bool,
		in msDelay: Int = .zero,
		onBecome: (() -> Void)? = nil
	) {
		self.become = become
		self.msDelay = msDelay
		self.onBecome = onBecome
	}
	
	public func body(content: Content) -> some View {
		ZStack(alignment: .topLeading) {
			content
				.introspectTextField { textField in
					self.textField ??= textField
				}
				/*
				.apply(when: textField.isNotSet) {
					$0.introspectTextField { textField in
						self.textField ??= textField
					}
				}
				*/
				.zIndex(20)
				
				if become && textField.isSet {
					Pixel()
						.onAppear(perform: becomeFirstResponder)
						.onDisappear(reset: $textField)
						.zIndex(10)
				}
		}
	}
	
	private func becomeFirstResponder() {
		if msDelay.isZero {
			textField?.becomeFirstResponder()
			onBecome?()
		} else {
			execute(in: msDelay) {
				textField?.becomeFirstResponder()
				onBecome?()
			}
		}
	}
}

public struct ReturnKeyType: ViewModifier {
	@State private var textField: UITextField?
	private let type: UIReturnKeyType
	
	public init(
		_ type: UIReturnKeyType
	) {
		self.type = type
	}
	
	public func body(content: Content) -> some View {
		ZStack(alignment: .topLeading) {
			content
				.introspectTextField { textField in
					self.textField ??= textField
				}
				/*
				.apply(when: textField.isNotSet) {
					$0.introspectTextField { textField in
						self.textField ??= textField
					}
				}
				*/
				.zIndex(20)
			
			if let field = textField {
				Pixel()
					.onAppear {
						field.returnKeyType = self.type
					}
					.zIndex(10)
			}
		}
	}
}

public extension View {
	func becomeFirstResponder(when condition: Bool) -> some View {
		modifier(BecomeFirstResponder(condition))
		/*
		apply(when: condition) { view in
			view.introspectTextField { field in
				field.becomeFirstResponder()
			}
		}
		*/
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
		modifier(BecomeFirstResponder(true, in: ms))
		/*
		introspectTextField { field in
			execute(in: ms) {
				field.becomeFirstResponder()
			}
		}
		*/
	}
	
	func returnKeyType(_ type: UIReturnKeyType) -> some View {
		modifier(ReturnKeyType(type))
		/*
		introspectTextField { field in
			field.returnKeyType = type
		}
		*/
	}
}
