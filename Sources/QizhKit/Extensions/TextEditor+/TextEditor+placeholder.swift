//
//  TextEditor+placeholder.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.04.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

#if canImport(UIKit)
import SwiftUI

extension TextEditor {
	/// Default `TextEditor` insets
	@inlinable public static var defaultTextEditorInsets: EdgeInsets {
		EdgeInsets(
				 top: 8,
			 leading: 4,
			  bottom: 8,
			trailing: 4
		)
	}
}

extension View {
	/// Adds a placeholder view behind a TextEditor that becomes visible when the text is empty.
	/// - Parameters:
	///   - placeholder: A view displayed when no text is entered.
	///   - alignment: Alignment of the ZStack that hosts the editor and placeholder.
	///   - text: The current text bound to the TextEditor. The placeholder is shown when this value is empty.
	///   - compact: If true, removes extra default editor padding to better align the placeholder.
	/// - Note:
	/// Use `.textEditorClearBackgroundAppearance()` to support iOS 15 and earlier. Apply it in your root app view and in preview providers.
	@inlinable public func placeholder(
		_ placeholder: some View,
		alignment: Alignment = .topLeading,
		editing text: String,
		compact: Bool
	) -> some View {
		self.placeholder(
			placeholder,
			alignment: alignment,
			visible: text.isEmpty,
			compact: compact
		)
	}
	
	/// Adds a placeholder view behind a TextEditor that becomes visible based on a condition.
	/// - Parameters:
	///   - placeholder: A view displayed when no text is entered.
	///   - alignment: Alignment of the ZStack that hosts the editor and placeholder.
	///   - visible: Controls whether the placeholder is visible.
	///   - compact: If true, removes extra default editor padding to better align the placeholder.
	/// - Note:
	/// Use `.textEditorClearBackgroundAppearance()` to support iOS 15 and earlier. Apply it in your root app view and in preview providers.
	@inlinable public func placeholder(
		_ placeholder: some View,
		alignment: Alignment = .topLeading,
		visible: Bool,
		compact: Bool
	) -> some View {
		self.placeholder(
			alignment: alignment,
			visible: visible,
			compact: compact
		) {
			placeholder
		}
	}
	
	/// Adds a placeholder view behind a TextEditor that becomes visible based on a condition.
	/// - Parameters:
	///   - alignment: Alignment of the ZStack that hosts the editor and placeholder.
	///   - visible: Controls whether the placeholder is visible.
	///   - compact: If true, removes extra default editor padding to better align the placeholder.
	///   - placeholder: A view displayed when no text is entered.
	/// - Note:
	/// Use `.textEditorClearBackgroundAppearance()` to support iOS 15 and earlier. Apply it in your root app view and in preview providers.
	public func placeholder(
		alignment: Alignment = .topLeading,
		visible: Bool,
		compact: Bool,
		placeholder: () -> some View
	) -> some View {
		ZStack(alignment: alignment) {
			self
				.scrollContentBackground(.hidden)
				.padding(compact ? -TextEditor.defaultTextEditorInsets : .zero)
				.zIndex(20)
			
			if visible {
				placeholder()
					.foregroundPlaceholder()
					.padding(compact ? .zero : TextEditor.defaultTextEditorInsets)
					.zIndex(10)
					.transition(.offset(x: 16) + .opacity)
			}
		}
		.animation(.spring, value: visible)
	}
}
#endif

