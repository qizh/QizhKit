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
		if let tintColor = tintColor {
			newSafariViewController.preferredControlTintColor = tintColor
		}
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
	private let title: String?
	private let tint: UIColor?
	private let content: Content
	private let isActive: Binding<Bool>?
	private let onDismiss: (() -> Void)?
	
	@State private var isPresented = false
	
	@Environment(\.colorScheme) private var colorScheme: ColorScheme
	
	public init(
		opening url: URL,
		title: String? = .none,
		tint: UIColor? = .none,
		isActive: Binding<Bool>? = .none,
		onDismiss: (() -> Void)? = .none,
		@ViewBuilder content: () -> Content
	) {
		self.url = url
		self.title = title
		self.tint = tint
		self.isActive = isActive
		self.onDismiss = onDismiss
		self.content = content()
	}
	
	public init <S> (
		_ title: S,
		opening url: URL,
		tint: UIColor? = .none,
		isActive: Binding<Bool>? = .none,
		onDismiss: (() -> Void)? = .none
	) where S: StringProtocol, Content == Text {
		self.url = url
		self.title = String(title)
		self.tint = tint
		self.isActive = isActive
		self.onDismiss = onDismiss
		self.content = Text(title)
	}
	
	public var body: some View {
		content
			.button(action: openURL)
			.safariView(
				isPresented: isActive ?? $isPresented,
				onDismiss: onDismiss
			) {
				BetterSafariView.SafariView(url: url)
					.preferredControlTintColor(tint)
				/*
				if let tint = tint, #available(iOS 14.0, *) {
					return BetterSafariView.SafariView(url: url)
						.preferredControlTintColor(tint)
				} else {
					return BetterSafariView.SafariView(url: url)
				}
				*/
			}
	}
	
	/*
	public var body: some View {
		if fullScreen, #available(iOS 14.0, *) {
			content
				.button(action: openURL)
				.fullScreenCover(isPresented: isActive ?? $isPresented, content: safariView)
		} else {
			content
				.button(action: openURL)
				.sheet(isPresented: isActive ?? $isPresented, content: safariView)
		}
	}
	
	@ViewBuilder
	private func safariView() -> some View {
		if #available(iOS 14.0, *) {
			SafariView(showing: url, title: title)
				// .ignoresSafeArea(.container, edges: .top)
				.environment(\.colorScheme, self.colorScheme)
		} else {
			SafariView(showing: url, title: title)
				.edgesIgnoringSafeArea(.top)
				.environment(\.colorScheme, self.colorScheme)
		}
	}
	*/
	
	// @available(iOSApplicationExtension, unavailable)
	private func openURL() {
		UIApplication.shared
			.open(
				url,
				options: [.universalLinksOnly: true]
			) { success in
				guard not(success) else { return }
				if let isActive = self.isActive {
					isActive.wrappedValue = true
				} else {
					isPresented = true
				}
			}
	}
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

public extension View {
	@ViewBuilder
	func asSafariButton(
		opening url: URL?,
		      title: String? = .none,
		       tint: UIColor? = .none,
		   isActive: Binding<Bool>? = .none,
		  onDismiss: (() -> Void)? = .none
	) -> some View {
		if let url = url?.withSupportedSafariScheme {
			SafariButton(
				  opening: url,
				    title: title,
				     tint: tint,
				 isActive: isActive,
				onDismiss: onDismiss
			) {
				self
			}
		} else {
			self
		}
	}
	
	/*
	@ViewBuilder
	func asSafariButton(
		opening url: URL?,
			  title: String? = .none,
		   isActive: Binding<Bool>? = .none,
		  onDismiss: (() -> Void)? = .none
	) -> some View {
		if let url = url?.withSupportedSafariScheme {
			self.safariView(
				isPresented: <#T##Binding<Bool>#>,
				onDismiss: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>,
				content: <#T##() -> SafariView#>
			)
			SafariButton(
				 opening: url,
				   title: title,
				isActive: isActive
			) {
				self
			}
		} else {
			self
		}
	}
	*/

	@available(iOS 14.0, *)
	@ViewBuilder
	func asLink(opening url: URL?) -> some View {
		if let url = url {
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
