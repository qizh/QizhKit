//
//  WebpageScreen.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 18.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

#if canImport(UIKit)
import SwiftUI
import UniformTypeIdentifiers

public struct WebpageScreen: View {
	private let title: Text
	private let source: WebView.Source
	
	@State private var scroll: CGPoint = .zero
	
	@Environment(\.colorScheme) private var colorScheme
	
	public init(title: Text, name: String, subdirectory: String) {
		self.init(
			title: title,
			source: Bundle.main.url(
				forResource: name,
				withExtension: "html",
				subdirectory: subdirectory
			)
			.map(WebView.Source.url)
			.or(.none)
		)
	}
	
	public init(title: Text, source: WebView.Source) {
		self.title = title
		self.source = source
	}
	
    public var body: some View {
		WebView(showing: source)
			.navigationTitle(title)
			.navigationBarTitleDisplayMode(.large)
			.toolbar {
				ToolbarItem(placement: .navigationBarTrailing) {
					if source.isDebug {
						Label {
							Text("Copy", comment: "Copy button text")
						} icon: {
							Image(systemName: "doc.on.doc")
						}
						.button(action: copySource)
					}
				}
				
				ToolbarItem(placement: .navigationBarTrailing) {
					if source.isDebug, source.string.isNotEmpty {
						shareButton
					}
				}
			}
			.edgesIgnoringSafeArea(.vertical)
			
			/// Debug Color Scheme
			// .overlay(debugColorScheme, alignment: .center)
    }
	
	private var debugColorScheme: some View {
		LabeledViews {
			colorScheme.caseView(label: "color scheme")
		}
	}
	
	private func copySource() {
		UIPasteboard.general.string = source.string
	}
	
	@ViewBuilder
	private var shareButton: some View {
		let filenameDate = Date.now
			.formatted(date: .abbreviated, time: .standard)
			.replacing(.colon, with: .minus)
		
		if let data = source.string.data(using: .utf8),
		   let fileURL = sharedFileURL(
				named: "\(source.debugName) \(filenameDate)",
				for: data
		   ) {
			ShareLink(
				item: fileURL,
				subject: title
			)
		} else {
			ShareLink(
				item: source.string,
				subject: title,
				preview: SharePreview(title)
			)
		}
	}
	
	private func sharedFileURL(named name: String, for data: Data) -> URL? {
		let fileExtension: String
		switch source.type {
		case .unknown: 	fileExtension = "txt"
		case .json: 	fileExtension = "json"
		case .csv: 		fileExtension = "csv"
		case .log: 		fileExtension = "log"
		}
		
		do {
			let manager = FileManager.default
			let cachesURL = try manager.url(
				for: .cachesDirectory,
				in: .userDomainMask,
				appropriateFor: .none,
				create: true
			)
			
			let folderURL = cachesURL
				.appending(path: "Shared Files", directoryHint: .isDirectory)
			
			if !manager.fileExists(atPath: folderURL.path) {
				try manager.createDirectory(
					at: folderURL,
					withIntermediateDirectories: true,
					attributes: nil
				)
			}
			
			let url = folderURL
				.appendingPathComponent(name)
				.appendingPathExtension(fileExtension)
			
			let didCreateFile = manager.createFile(
				atPath: url.path,
				contents: data,
				attributes: .none
			)
			
			if didCreateFile {
				return url
			} else {
				print("::web > failed to save file")
				return .none
			}
		} catch {
			print("::web > failed to create share file because \(error)")
			return .none
		}
	}
	
	private func share(_ data: Data) {
		let fileExtension: String
		switch source.type {
		case .unknown: 	fileExtension = "txt"
		case .json: 	fileExtension = "json"
		case .csv: 		fileExtension = "csv"
		case .log: 		fileExtension = "log"
		}
		
		let tempDirURL = URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
		let dateString = Date.now
			.format(date: .short, time: .medium, relative: false, context: .middleOfSentence)
			.replacing(CharacterSet.decimalDigits.inverted, with: .minus)
			.replacing(.minus + .minus, with: .minus)
		
		let fileURL = tempDirURL
			.appendingPathComponent("output" + .minus + dateString)
			.appendingPathExtension(fileExtension)
		
		let fileManager = FileManager.default
		let didCreateFile = fileManager.createFile(
			atPath: fileURL.path,
			contents: data,
			attributes: .none
		)
		
		let shareController = UIActivityViewController(
			activityItems: didCreateFile ? [fileURL] : [source.string],
			applicationActivities: .empty
		)
		shareController.excludedActivityTypes = .empty
		WindowUtils.topViewController()?
			.present(
				shareController,
				animated: true,
				completion: nil
			)
	}
}

// MARK: Previews

#if DEBUG
struct WebpageScreen_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			NavigationView {
				WebpageScreen(
					title: Text(verbatim: "Terms of Service"),
					name: "tos",
					subdirectory: "Pages"
				)
			}
//			.previewDifferentDevices()
			.previewAllColorSchemes()
			
			NavigationView {
				WebpageScreen(
					title: Text(verbatim: "Variables"),
					source: .debug(#"{ "data": "none" }"#, .json)
				)
			}
			.previewAllColorSchemes()
			
			/*
			TabView(selection: .constant(1)) {
				WebpageScreen(
					title: "Terms of Service",
					name: "tos",
					subdirectory: "Pages"
				)
				.inNavigationViewWithTitleAndBack(title: "Terms of Service", back: "Settings")
				.tag(1)
			}
			.edgesIgnoringSafeArea(.top)
			*/
		}
//		.accentColor(.cooktourTextAccent)
//		.canForceNavigationBarHidden()
    }
}
#endif
#endif
