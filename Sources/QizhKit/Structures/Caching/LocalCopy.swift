//
//  LocalCopy.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 20.08.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import Foundation

public struct LocalCopy<Model: Codable> {
	public let url: URL
	
	/// - Parameters:
	///   - path: Slash separated path or just a folder name.
	///   For example, `"cache"` or `"caches/requests"`.
	///   - name: File name. Model class name by default.
	///   - type: File type. json by default.
	
	public init(
		path: String,
		name: String = "\(Model.self)",
		type: CommonFileType = .json
	) throws {
		let manager = FileManager.default
		
		let cachesURL = try manager.url(
			for: .cachesDirectory,
			in: .userDomainMask,
			appropriateFor: .none,
			create: true
		)
		
		var folderURL = cachesURL
		if path.isNotEmpty {
			let pathComponents = path.components(separatedBy: String.slash)
			for folder in pathComponents {
				folderURL = folderURL.appendingPathComponent(folder, isDirectory: true)
			}
		}
		
		if !manager.fileExists(atPath: folderURL.path) {
			try manager.createDirectory(
				at: folderURL,
				withIntermediateDirectories: true,
				attributes: nil
			)
		}
		
		self.url = folderURL
			.appendingPathComponent(name)
			.appendingPathExtension(type.rawValue)
	}
	
	// MARK: Properties
	
	public var date: Date? {
		do {
			let attributes = try FileManager.default
				.attributesOfItem(atPath: url.path)
			return attributes[.modificationDate] as? Date
		} catch {
			print("::copy > file attributes failure < \(error.localizedDescription)")
			return .none
		}
	}
	
	@inlinable
	public var isAvailable: Bool {
		FileManager.default.fileExists(atPath: url.path)
	}
	
	// MARK: Actions
	
	public func get(using decoder: JSONDecoder? = .none) async throws -> Model {
		try await Task {
			let data = try Data(contentsOf: url)
			let jsonDecoder = decoder ?? JSONDecoder()
			if #available(iOS 15.0, *), decoder.isNotSet {
				jsonDecoder.allowsJSON5 = true
			}
			let model = try jsonDecoder.decode(Model.self, from: data)
			return model
		}
		.value
	}
	
	public func save(
		_ model: Model,
		in priority: TaskPriority? = .background,
		using encoder: JSONEncoder? = .none
	) async throws {
		try await Task(priority: priority) {
			let encoder = encoder ?? JSONEncoder()
			let data = try encoder.encode(model)
			
			let success = FileManager.default
				.createFile(
					atPath: url.path,
					contents: data,
					attributes: nil
				)
			
			if not(success) {
				throw LocalCopyError.fileCreationFailed
			}
		}
		.value
	}
	
	public func delete() {
		try? FileManager.default.removeItem(atPath: url.path)
	}
}

public enum LocalCopyError: LocalizedError {
	case fileCreationFailed
	
	public var errorDescription: String? {
		switch self {
		case .fileCreationFailed: return "FileManager's createFile function returned false"
		}
	}
}

// MARK: File Type

public struct CommonFileType: RawRepresentable,
							  ExpressibleByStringLiteral,
							  LosslessStringConvertible {
	public let rawValue: String
	public init(rawValue: String) { self.rawValue = rawValue }
	
	@inlinable public init(stringLiteral value: String) { self.init(rawValue: value) }
	@inlinable public init(_ description: String) { self.init(rawValue: description) }
	
	@inlinable public var description: String { rawValue }
	
	@inlinable public static var json: CommonFileType { "json" }
	@inlinable public static var txt: CommonFileType { "txt" }
	@inlinable public static var html: CommonFileType { "html" }
	@inlinable public static var dat: CommonFileType { "dat" }
}
