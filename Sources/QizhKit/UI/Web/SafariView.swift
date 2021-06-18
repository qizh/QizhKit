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
		
		guard let originalURL = url else { return }
		
		/// Supported by `SFSafariViewController`
		let supportedSchemes = ["http", "https"]
		
		/// Update with supported scheme if needed
		
		let url: URL
		if let scheme = originalURL.scheme,
		   supportedSchemes.contains(scheme) {
			/// Scheme is supported
			url = originalURL
		} else {
			/// Set `http` scheme
			var components = URLComponents(url: originalURL, resolvingAgainstBaseURL: true)
			components?.scheme = supportedSchemes.first
			if let updatedURL = components?.url {
				/// Succeed
				url = updatedURL
			} else {
				/// Failed
				return
			}
		}
		
		/// Create a new safari child view controller with the `url`
		
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
	private let content: Content
	private let isActive: Binding<Bool>?
	
	@State private var isPresented = false
	
	@Environment(\.colorScheme) private var colorScheme: ColorScheme
	
	public init(
		opening url: URL,
		title: String? = nil,
		isActive: Binding<Bool>? = nil,
		@ViewBuilder content: () -> Content
	) {
		self.url = url
		self.title = title
		self.isActive = isActive
		self.content = content()
	}
	
	public init<S>(
		_ title: S,
		opening url: URL,
		isActive: Binding<Bool>? = nil
	) where S: StringProtocol, Content == Text {
		self.url = url
		self.title = String(title)
		self.isActive = isActive
		self.content = Text(title)
	}
	
	public var body: some View {
		content
			.button {
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
			.sheet(isPresented: isActive ?? $isPresented) {
				SafariView(showing: self.url, title: self.title)
					.edgesIgnoringSafeArea(.all)
					.environment(\.colorScheme, self.colorScheme)
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

public extension URL {
	var buttonLabel: String {
		guard let host = host else { return absoluteString }
		return host.deleting(prefix: "www.") + (path.count > 1 ? path : "")
	}
}

public extension View {
	@ViewBuilder
	func asSafariButton(
		opening url: URL?,
		      title: String? = nil,
		   isActive: Binding<Bool>? = nil
	) -> some View {
		if let url = url {
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
