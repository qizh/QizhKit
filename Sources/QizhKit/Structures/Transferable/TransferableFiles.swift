//
//  TransferableFiles.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 04.09.2025.
//  Copyright © 2025 Serhii Shevchenko. All rights reserved.
//

import Foundation
public import CoreTransferable

/// A shareable JSON file with a filename.
public struct JSONDocument: Transferable {
	public init(
		with data: Data,
		named filename: String
	) {
		self.filename = filename
		self.data = data
	}
	
	@inlinable public init(
		with jsonString: String,
		named filename: String
	) {
		self.init(
			with: Data(jsonString.utf8),
			named: filename
		)
	}
	
	public let filename: String
	public let data: Data
	
	public static var transferRepresentation: some TransferRepresentation {
		/// Export as a real file (so you control the extension & filename)
		FileRepresentation(exportedContentType: .json) { item in
			let url = FileManager.default.temporaryDirectory
				.appendingPathComponent(item.filename)
				.appendingPathExtension("json")
			try item.data.write(to: url, options: .atomic)
			return .init(url) /// SentTransferredFile
		}
	}
}

