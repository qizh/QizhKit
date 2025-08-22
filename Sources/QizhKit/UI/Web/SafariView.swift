//
//  SafariView.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 08.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import UIKit
import SafariServices
import BetterSafariView
import QizhMacroKit

// MARK: VC

public final class CooktourSafariViewController: UIViewController {
	public var tintColor: UIColor?
	public var safariTitle: String?
	public var url: URL? {
		didSet {
			configureChildViewController()
		}
	}
	
	private var safariViewController: SFSafariViewController?
	
	public override func viewDidLoad() {
		super.viewDidLoad()
		configureChildViewController()
	}
	
	private func configureChildViewController() {
		
		/// Remove the previous safari child view controller if not nil
		
		if let safariViewController = safariViewController {
			safariViewController.willMove(toParent: self)
			safariViewController.view.removeFromSuperview()
			safariViewController.removeFromParent()
			self.safariViewController = nil
		}
		
		guard let url = url?.withSupportedSafariScheme else { return }
		
		/// Create a new safari child view controller with the `url`
		
		/*
		var configuration = SFSafariViewController.Configuration()
		configuration.barCollapsingEnabled = true
		let newSafariViewController = SFSafariViewController(url: url, configuration: configuration)
		*/
		let newSafariViewController = SFSafariViewController(url: url)
		newSafariViewController.title = safariTitle
		title = safariTitle
		#if os(iOS)
		if let tintColor = tintColor {
			newSafariViewController.preferredControlTintColor = tintColor
		}
		#endif
		addChild(newSafariViewController)
		newSafariViewController.view.frame = view.frame
		view.addSubview(newSafariViewController.view)
		newSafariViewController.didMove(toParent: self)
		self.safariViewController = newSafariViewController
	}
}

// MARK: Button

public struct SafariButton<Content>: View where Content: View {
	private let url: URL
	private let tint: Color?
	private let content: Content
	private let openStyle: SafariButtonOpenStyle
	private let dismissButton: SFSafariViewController.DismissButtonStyle
	private let isActive: Binding<Bool>?
	private let onOpen: (() -> Void)?
	private let onDismiss: (() -> Void)?
	
	@State private var isPresented = false
	
	@Environment(\.colorScheme) private var colorScheme
	
	public init(
		opening url: URL,
		tintColor tint: Color?,
		openStyle: SafariButtonOpenStyle = .push,
		dismissButton: SFSafariViewController.DismissButtonStyle = .done,
		isActive: Binding<Bool>? = .none,
		onOpen: (() -> Void)? = .none,
		onDismiss: (() -> Void)? = .none,
		@ViewBuilder content: () -> Content
	) {
		self.url = url
		self.tint = tint
		self.openStyle = openStyle
		self.dismissButton = dismissButton
		self.isActive = isActive
		self.onOpen = onOpen
		self.onDismiss = onDismiss
		self.content = content()
	}
	
	@inlinable public init(
		title: Text,
		opening url: URL,
		tintColor tint: Color?,
		openStyle: SafariButtonOpenStyle = .push,
		dismissButton: SFSafariViewController.DismissButtonStyle = .done,
		isActive: Binding<Bool>? = .none,
		onOpen: (() -> Void)? = .none,
		onDismiss: (() -> Void)? = .none
	) where Content == Text {
		self.init(
			opening: url,
			tintColor: tint,
			openStyle: openStyle,
			dismissButton: dismissButton,
			isActive: isActive,
			onOpen: onOpen,
			onDismiss: onDismiss,
			content: {
				title
			}
		)
	}
	
	public var body: some View {
		content
			.button(action: openURL)
			.apply { button in
				switch openStyle {
				case .push:
					button
						.safariView(
							isPresented: isActive ?? $isPresented,
							onDismiss: onDismiss
						) {
							BetterSafariView.SafariView(url: url)
								.preferredControlAccentColor(tint)
								.dismissButtonStyle(.close)
						}
				case .sheet:
					button
						.sheet(
							isPresented: isActive ?? $isPresented,
							onDismiss: onDismiss
						) {
							BetterSafariView.SafariView(url: url)
								.preferredControlAccentColor(tint)
						}
				case .fullscreenCover:
					button
						.fullScreenCover(
							isPresented: isActive ?? $isPresented,
							onDismiss: onDismiss
						) {
							BetterSafariView.SafariView(url: url)
								.preferredControlAccentColor(tint)
						}
				}
			}
	}
	
	private func openURL() {
		UIApplication.shared
			.open(
				url,
				options: [.universalLinksOnly: true]
			) { success in
				guard not(success) else { return }
				onOpen?()
				if let isActive = self.isActive {
					isActive.wrappedValue = true
				} else {
					isPresented = true
				}
			}
	}
}

@CaseName
public enum SafariButtonOpenStyle: Hashable, Sendable, CaseIterable {
	case push
	case sheet
	case fullscreenCover
}

extension SafariButtonOpenStyle: CustomStringConvertible {
	@inlinable public var description: String { caseName }
}

extension SafariButtonOpenStyle: Identifiable {
	@inlinable public var id: Self { self }
}

// MARK: View

public struct SafariView: UIViewControllerRepresentable {
	private let url: URL?
	private let title: String?
	
	public init(showing url: URL? = nil, title: String? = nil) {
		self.url = url
		self.title = title
	}

	public func makeUIViewController(context: Context) -> CooktourSafariViewController {
		CooktourSafariViewController()
	}

	public func updateUIViewController(_ safariViewController: CooktourSafariViewController, context: Context) {
		safariViewController.tintColor = Color.accentColor.uiColor()
		safariViewController.title = title
		safariViewController.safariTitle = title
		safariViewController.url = url
	}
}

// MARK: Extensions

extension URL {
	public var buttonLabel: String {
		guard let host = host else { return absoluteString }
		return host.deleting(prefix: "www.") + (path.count > 1 ? path : "")
	}
	
	public var withSupportedSafariScheme: URL? {
		/// Supported by `SFSafariViewController`
		let supportedSchemes = ["http", "https"]
		
		/// Update with supported scheme if needed
		if let scheme = self.scheme,
		   supportedSchemes.contains(scheme) {
			/// Scheme is supported
			return self
		} else {
			/// Set `http` scheme
			var components = URLComponents(url: self, resolvingAgainstBaseURL: true)
			components?.scheme = supportedSchemes.first
			if let updatedURL = components?.url {
				/// Succeed
				return updatedURL
			} else {
				/// Failed
				return .none
			}
		}
	}
}

extension View {
	@ViewBuilder
	public func asSafariButton(
		opening url: URL?,
		tintColor tint: Color? = .none,
		openStyle: SafariButtonOpenStyle = .push,
		dismissButton: BetterSafariView.SafariView.DismissButtonStyle = .done,
		isActive: Binding<Bool>? = .none,
		onOpen: (() -> Void)? = .none,
		onDismiss: (() -> Void)? = .none
	) -> some View {
		if let url = url?.withSupportedSafariScheme {
			SafariButton(
				opening: url,
				tintColor: tint,
				openStyle: openStyle,
				dismissButton: dismissButton,
				isActive: isActive,
				onOpen: onOpen,
				onDismiss: onDismiss
			) {
				self
			}
		} else {
			self
		}
	}
	
	@ViewBuilder
	public func asLink(opening url: URL?) -> some View {
		if let url {
			Link(destination: url) {
				self
			}
		} else {
			self
		}
	}
}

// MARK: Previews

#if DEBUG
struct SafariView_Previews: PreviewProvider {
    static var previews: some View {
		SafariView(showing: URL(string: "https://google.com"))
			.edgesIgnoringSafeArea(.all)
    }
}
#endif
