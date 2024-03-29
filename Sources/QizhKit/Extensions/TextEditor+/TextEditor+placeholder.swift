//
//  TextEditor+placeholder.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.04.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

@available(iOS 14.0, *)
extension TextEditor {
	/// Default `TextEditor` insets
	@inlinable
	public static var defaultTextEditorInsets: EdgeInsets {
		EdgeInsets(
				 top: 8,
			 leading: 4,
			  bottom: 8,
			trailing: 4
		)
	}
}

@available(iOS 14.0, *)
extension View {
	/// `TextEditor` placeholder text placed under the editor
	/// - Parameters:
	///   - placeholder: Placeholder view visible when no text enetered
	///   - alignment: `ZStack` alignment
	///   - text: Text produced by TextEditor
	///   - compact: Removes extra editor padding when set to `true`
	/// - Note:
	/// `.textEditorClearBackgroundAppearance()` view modifier required
	/// to make it work on iOS 15 or earlier.
	/// Add it in you main app view, and in preview provider view.
	@inlinable
	public func placeholder <Placeholder: View> (
		_ placeholder: Placeholder,
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
	
	/// `TextEditor` placeholder text placed under the editor
	/// - Parameters:
	///   - placeholder: Placeholder view visible when no text enetered
	///   - alignment: `ZStack` alignment
	///   - visible: Condition for showing placeholder
	///   - compact: Removes extra editor padding when set to `true`
	/// - Note:
	/// `.textEditorClearBackgroundAppearance()` view modifier required
	/// to make it work on iOS 15 or earlier.
	/// Add it in you main app view, and in preview provider view.
	@inlinable
	public func placeholder <Placeholder: View> (
		_ placeholder: Placeholder,
		alignment: Alignment = .topLeading,
		visible: Bool,
		compact: Bool
	) -> some View {
		self.placeholder(alignment: alignment, visible: visible, compact: compact) {
			placeholder
		}
	}
	
	/// `TextEditor` placeholder text placed under the editor
	/// - Parameters:
	///   - alignment: `ZStack` alignment
	///   - visible: Condition for showing placeholder
	///   - compact: Removes extra editor padding when set to `true`
	///   - placeholder: Placeholder view visible when no text enetered
	/// - Note:
	/// `.textEditorClearBackgroundAppearance()` view modifier required
	/// to make it work on iOS 15 or earlier.
	/// Add it in you main app view, and in preview provider view.
	public func placeholder <Placeholder: View> (
		alignment: Alignment = .topLeading,
		visible: Bool,
		compact: Bool,
		placeholder: () -> Placeholder
	) -> some View {
		ZStack(alignment: alignment) {
			self
				.apply { editor in
					if #available(iOS 16.0, *) {
						editor.scrollContentBackground(.hidden)
					} else {
						editor
					}
				}
				.padding(
					compact
						? -TextEditor.defaultTextEditorInsets
						: .zero
				)
				.zIndex(20)
			
			if visible {
				placeholder()
					.foregroundPlaceholder()
					.padding(
						compact
							? .zero
							: TextEditor.defaultTextEditorInsets
					)
					.zIndex(10)
					.transition(.offset(x: 16), .opacity)
			}
		}
		.animation(.spring(), value: visible)
	}
}

extension View {
	/// Modifies the global `UITextView` appearance
	/// to set its `backgroundColor` to `.clear`
	@inlinable
	public func textEditorClearBackgroundAppearance() -> some View {
		self.onAppear {
			if #unavailable(iOS 16.0) {
				UITextView.appearance().backgroundColor = .clear
			}
		}
	}
}
