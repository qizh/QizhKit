//
//  WebpageScreen.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 18.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import UniformTypeIdentifiers

public struct WebpageScreen: View {
	private let title: String
	private let source: WebView.Source
	
	@State private var scroll: CGPoint = .zero
	
	@Environment(\.colorScheme) private var colorScheme
	
	public init(title: String, name: String, subdirectory: String) {
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
	
	public init(title: String, source: WebView.Source) {
		self.title = title
		self.source = source
	}
	
    public var body: some View {
//		WebView(showing: source, scroll: $scroll)
		WebView(showing: source)
			.navTitle(title, .large)
			.apply { view in
				if #available(iOS 14, *) {
					view
						.toolbar {
							ToolbarItem(placement: .navigationBarTrailing) {
								if source.isDebug {
									Label("Copy", systemImage: "doc.on.doc")
										.button(action: copySource)
								}
							}
							
							ToolbarItem(placement: .navigationBarTrailing) {
								if source.isDebug, source.string.isNotEmpty {
									Label("Share", systemImage: "square.and.arrow.up")
										.button(action: copySource)
								}
							}
						}
				} else {
					view
						.navigationBarItems(trailing: trailingButtons)
				}
			}
			/*
			.autoShowHeaderBackground(
				     on:  scroll,
				  after:  10,
				measure: .continuous,
				  style: .auto(colorScheme)
			)
			*/
			.edgesIgnoringSafeArea(.vertical)
			
			/// Debug Color Scheme
			// .overlay(debugColorScheme, alignment: .center)
    }
	
	private var debugColorScheme: some View {
		VStack.LabeledViews {
			colorScheme.labeledView(label: "color scheme")
		}
	}
	
	@ViewBuilder private var trailingButtons: some View {
		HStack(alignment: .lastTextBaseline) {
			if source.isDebug {
				/// Copy
				Image(systemName: "doc.on.doc")
					.padding(4)
					.button(action: copySource)
				
				if source.string.isNotEmpty {
					Image(systemName: "square.and.arrow.up")
						.padding(4)
						.button(action: shareSourceFile)
				}
			}
		}
		.imageScale(.large)
	}
	
	private func copySource() {
		UIPasteboard.general.string = source.string
	}
	
	private func shareSourceFile() {
		guard let data = source.string.data(using: .utf8) else {
			print("Failed to create data")
			return
		}
		
		let fileExtension: String
		switch source.type {
		case .unknown: 	fileExtension = "txt"
		case .json: 	fileExtension = "json"
		case .csv: 		fileExtension = "csv"
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
		WindowUtils.currentWindow?.rootViewController?
			.present(
				shareController,
				animated: true,
				completion: nil
			)
	}
}

#if DEBUG
struct WebpageScreen_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			NavigationView {
				WebpageScreen(
					title: "Terms of Service",
					name: "tos",
					subdirectory: "Pages"
				)
			}
//			.previewDifferentDevices()
			.previewAllColorSchemes()
			
			NavigationView {
				WebpageScreen(
					title: "Variables",
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
		.accentColor(.cooktourTextAccent)
		.canForceNavigationBarHidden()
    }
}
#endif
