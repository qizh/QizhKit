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
	
	public init?(
		path: String,
		name: String = "\(Model.self)",
		type: FileType = .json
	) {
		let manager = FileManager.default
		do {
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
		} catch {
			print("LocalCopy failed to create an URL because \(error)")
			return nil
		}
	}
	
	public var date: Date? {
		do {
			let attributes = try FileManager.default
				.attributesOfItem(atPath: url.path)
			return attributes[.modificationDate] as? Date
		} catch {
			return .none
		}
	}
	
	public func get(using decoder: JSONDecoder? = .none) async throws -> Model {
		let data = try Data(contentsOf: url)
		let decoder = decoder ?? JSONDecoder()
		let model = try decoder.decode(Model.self, from: data)
		return model
	}
	
	@discardableResult
	public func save(_ model: Model, using encoder: JSONEncoder? = .none) async throws -> Bool {
		let encoder = encoder ?? JSONEncoder()
		
		let encodeTask = Task(priority: .background) {
			try encoder.encode(model)
		}
		
		let data = try await encodeTask.value
		
		let saveTask = Task(priority: .background) {
			FileManager.default
				.createFile(
					atPath: url.path,
					contents: data,
					attributes: nil
				)
		}
		
		return await saveTask.value
	}
	
	// MARK: File Type
	
	public struct FileType: RawRepresentable,
							ExpressibleByStringLiteral,
							LosslessStringConvertible {
		public let rawValue: String
		
		public init(rawValue: String) { self.rawValue = rawValue }
		public init(stringLiteral value: String) { self.rawValue = value }
		public init(_ description: String) { self.rawValue = description }
		
		public var description: String { rawValue }
		
		@inlinable public static var json: FileType { "json" }
		@inlinable public static var txt: FileType { "txt" }
		@inlinable public static var html: FileType { "html" }
		@inlinable public static var dat: FileType { "dat" }
	}
}
