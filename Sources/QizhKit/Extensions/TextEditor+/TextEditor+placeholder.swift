//
//  TextEditor+placeholder.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 24.04.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

fileprivate let textEditorInsets =
	EdgeInsets(
		     top: 8,
		 leading: 4,
		  bottom: 8,
		trailing: 4
	)

@available(iOS 14.0, *)
public extension TextEditor {
	/// Placeholder text placed under the editor
	/// - Parameters:
	///   - placeholder: Placeholder string visible when no text enetered
	///   - text: Text produced by TextEditor
	///   - compact: Removes extra editor padding when set to `true`
	/// - Note:
	/// `.textEditorClearBackgroundAppearance()` view modifier required to make it work.
	/// Add it in you main app view, and in preview provider view
	func placeholder(
		_ placeholder: String,
		editing text: String,
		compact: Bool
	) -> some View {
		ZStack {
			self
				.padding(
					compact
						? -textEditorInsets
						: .zero
				)
				.zIndex(20)
			
			if text.isNotEmpty {
				Text(placeholder)
					.foregroundColor(\.placeholderText)
					.padding(
						compact
							? .zero
							: textEditorInsets
					)
					.maxWidth(.topLeading)
					.zIndex(10)
					.transition(.offset(x: 16), .opacity)
			}
		}
		.animation(.spring(), value: text.isEmpty)
	}
}

public extension View {
	/// Modifies the global `UITextView` appearance
	/// to set its `backgroundColor` to `.clear`
	@inlinable
	func textEditorClearBackgroundAppearance() -> some View {
		self.onAppear {
			UITextView.appearance().backgroundColor = .clear
		}
	}
}
