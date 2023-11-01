//
//  WebView.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 05.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import WebKit

public struct WebView: UIViewControllerRepresentable {
	private let source: Source
	private let baseUrl: URL?
	private let allowsBackForwardNavigationGestures: Bool
	private let allowsLinkPreview: Bool
	private let configuration: WKWebViewConfiguration?
	private let contentOffset: Binding<CGPoint>?
	
	public enum Source {
		case none
		case embed(_ code: String)
		case debug(
			_ code: String,
			_ type: SourceType = .unknown,
			_ name: String = Self.defaultDebugName
		)
		case  html(_ code: String)
		case  file(_ url: URL)
		case   url(_ url: URL)
		
		public enum SourceType: WithUnknown, EasyCaseComparable {
			case unknown
			case json
			case csv
			case log
		}
		
		public static let defaultDebugName = "Debug"
		
		public var isDebug: Bool {
			switch self {
			case .debug: return true
			    default: return false
			}
		}
		
		public var type: SourceType {
			switch self {
			case .debug(_, let type, _): return type
			default: return .unknown
			}
		}
		
		public var debugName: String {
			switch self {
			case .debug(_, _, let name): 	return name
			default: 						return Self.defaultDebugName
			}
		}
		
		public var string: String {
			switch self {
			case .none:               		return .empty
			case .embed(let code):    		return code
			case .debug(let code, _, _): 	return code
			case  .html(let code):    		return code
			case  .file(let url):     		return url.absoluteString
			case   .url(let url):     		return url.absoluteString
			}
		}
		
		public var url: URL? {
			switch self {
			case .embed,
				 .debug,
				 .html,
				 .none: 	      	return .none
			case .file(let url): 	return url
			case .url(let url): 	return url
			}
		}
	}
	
	public static func showing(_ source: Source) -> WebView {
		WebView(showing: source)
	}
	
	public init(
		showing source: Source,
		baseURL baseUrl: URL? = nil,
		allowsBackForwardNavigationGestures: Bool = false,
		allowsLinkPreview: Bool = true,
		configuration: WKWebViewConfiguration? = nil,
		scroll contentOffset: Binding<CGPoint>? = nil
	) {
		if case .embed(let code) = source {
			self.source = .html(WebView.emptyPage(withEmbedded: code))
		} else if case .debug(let code, _, _) = source {
			self.source = .html(WebView.debugPage(for: code))
		} else {
			self.source = source
		}
		
		self.baseUrl = baseUrl
		self.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
		self.allowsLinkPreview = allowsLinkPreview
		
		if let configuration = configuration {
			self.configuration = configuration
		} else {
			let prefs = WKWebpagePreferences()
			prefs.preferredContentMode = .mobile
			let config = WKWebViewConfiguration()
			config.allowsInlineMediaPlayback = true
			config.mediaTypesRequiringUserActionForPlayback = []
			config.defaultWebpagePreferences = prefs
			self.configuration = config
		}
		
		self.contentOffset = contentOffset
	}
	
	private static func emptyPage(withEmbedded code: String) -> String {
		" " + """
		<!doctype html>
		<head>
		  <meta charset="utf-8">
		  <title></title>
		  <meta name="description" content="">
		  <meta name="viewport" content="width=device-width, user-scalable=0">
		  <meta name="supported-color-schemes" content="light dark">
		  <meta name="color-scheme" content="light dark">
		  <style>
			html {
				height  : 100%;
				overflow: hidden;
			}
			body {
				height  : 100%;
				overflow: auto;
				margin: 0;
			}
			iframe {
				width: 100%;
				height: 100%;
			}
			audio,
			canvas,
			iframe,
			img,
			svg,
			video {
			  vertical-align: middle;
			}
			@media (prefers-color-scheme: dark) {
			  background-color: hsl(0, 0%, 0%)
			  .white {
				background-color: hsl(0, 0%, 100%)
			  }
			}
		  </style>
		</head>
		<body>
			\(code)
		</body>
		</html>
		"""
	}
	
	private static func debugPage(for code: String) -> String {
		" " + """
		<!doctype html>
		<head>
		  <meta charset="utf-8">
		  <title></title>
		  <meta name="description" content="">
		  <meta name="viewport" content="width=device-width">
		  <meta name="supported-color-schemes" content="light dark">
		  <meta name="color-scheme" content="light dark">
		  <style>
			pre {
			  vertical-align: middle;
			  font-family: Menlo,monospace;
			  font-size: small;
			  white-space: pre;
			  tab-size: 2;
			  /*
			  white-space: pre-wrap;
			  word-break: keep-all;
			  */
			}
			@media (prefers-color-scheme: dark) {
			  background-color: hsl(0, 0%, 0%)
			  .white {
			    background-color: hsl(0, 0%, 100%)
			  }
			}
		  </style>
		</head>
		<body>
			<pre>\(code)</pre>
		</body>
		</html>
		"""
	}

	public func makeCoordinator() -> WebViewDelegate {
		WebViewDelegate()
	}
	
	public func makeUIViewController(context: Context) -> EmbeddedWebViewController {
		let coordinator = context.coordinator
		coordinator.contentOffset = contentOffset
		let vc = EmbeddedWebViewController(
			configuration: configuration,
			delegate: coordinator
		)
		vc.webView.allowsBackForwardNavigationGestures = allowsBackForwardNavigationGestures
		vc.webView.allowsLinkPreview = allowsLinkPreview
		return vc
	}
	
	public func updateUIViewController(_ vc: EmbeddedWebViewController, context: Context) {
		if !context.coordinator.havePageSet {
			switch source {
			case .embed: preconditionFailure("`.embed` source should be converted to `.html` upon init")
			case .debug: preconditionFailure("`.debug` source should be converted to `.html` upon init")
			case .html(let code): vc.webView.loadHTMLString(code, baseURL: baseUrl)
			case .file(let url): vc.webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
			case .url(let url): vc.webView.load(URLRequest(url: url))
			case .none: break
			}
		}
	}
}

public class EmbeddedWebViewController: UIViewController {
	public let webView: WKWebView
	
	public init(configuration: WKWebViewConfiguration?, delegate: WebViewDelegate) {
		if let configuration = configuration {
			webView = WKWebView(frame: .zero, configuration: configuration)
		} else {
			webView = WKWebView()
		}
		
//		webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
		
		webView.navigationDelegate = delegate
		webView.scrollView.delegate = delegate
        super.init(nibName: nil, bundle: nil)
	}
	
	public required init?(coder: NSCoder) {
		webView = WKWebView()
		super.init(coder: coder)
	}
	
	public override func loadView() {
		view = webView
	}
	
	public override func viewDidLoad() {
		webView.scrollView.contentInsetAdjustmentBehavior = .never
		super.viewDidLoad()
	}
	
	public override func willMove(toParent parent: UIViewController?) {
		guard let vc = parent else { return }
		
		let standard = UINavigationBarAppearance()
		standard.configureWithDefaultBackground()
		vc.navigationItem.standardAppearance = standard
	}
}

public class WebViewDelegate: NSObject, WKNavigationDelegate, UIScrollViewDelegate {
	fileprivate var havePageSet = false
	fileprivate var havePageLoaded = false
	
	fileprivate var contentOffset: Binding<CGPoint>?
	
	public func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
		havePageSet = true
	}
	
	public func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
		havePageLoaded = true
		webView.scrollView.contentInsetAdjustmentBehavior = .automatic
	}
	
	public func scrollViewDidScroll(_ scrollView: UIScrollView) {
		contentOffset?.wrappedValue = scrollView.contentOffset.opposite
	}
}

#if DEBUG
struct WebView_Previews: PreviewProvider {
    static var previews: some View {
		Group {
//			WebView(showing: .embed(
//				#"""
//				<iframe width="560" height="315" src="https://www.youtube.com/embed/59Q_lhgGANc" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
//				"""#
//				))
			WebView(showing: .embed(
				#"""
				<iframe width="560" height="315" src="https://www.youtube.com/embed/Xss6ZlUYoGA" frameborder="0" allow="accelerometer; autoplay; encrypted-media; gyroscope; picture-in-picture" allowfullscreen></iframe>
				"""#
				))
			.aspectRatio(CGSize(width: 560, height: 315), contentMode: .fit)
			.previewLayout(.sizeThatFits)
			
			NavigationView {
				Bundle.main.url(
					forResource: "tos",
					withExtension: "html",
					subdirectory: "Pages"
				)
				.map(WebView.Source.url)
				.map(view: WebView.showing)
				.navigationBarTitle(Text("Terms of Service"), displayMode: .large)
				.edgesIgnoringSafeArea(.vertical)
			}

//			WebView(showing: .file(URL(fileReferenceLiteralResourceName: "tos.html")))
			
//			WebView(showing: .url(URL(string: "https://www.youtube.com/watch?v=59Q_lhgGANc")!))
			WebView(showing: .url(URL(string: "https://www.youtube.com/embed/59Q_lhgGANc")!))
//			WebView(showing: .url(URL(string: "https://www.youtube.com/watch?v=-syN8aFZz0w")!))
//			WebView(showing: .url(URL(string: "https://www.youtube.com/embed/-syN8aFZz0w")!))
//				.inNavigationViewWithLargeTitle(title: "Makeba")
		}
//		.previewAllColorSchemes()
    }
}
#endif
