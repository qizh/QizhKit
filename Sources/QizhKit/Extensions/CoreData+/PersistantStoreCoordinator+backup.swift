//
//  PersistantStoreCoordinator+backup.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 23.08.2021.
//

import CoreData
import Foundation

// MARK: Backup

/// Copied from https://oleb.net/blog/2018/03/core-data-sqlite-backup/

/// Safely copies the specified `NSPersistentStore` to a temporary file.
/// Useful for backups.
///
/// - Parameter index: The index of the persistent store in the coordinator's
///   `persistentStores` array. Passing an index that doesn't exist will trap.
///
/// - Returns: The URL of the backup file, wrapped in a TemporaryFile instance
///   for easy deletion.
extension NSPersistentStoreCoordinator {
	public func backupPersistentStore(atIndex index: Int) throws -> TemporaryFile {
		// Inspiration: https://stackoverflow.com/a/22672386
		// Documentation for NSPersistentStoreCoordinate.migratePersistentStore:
		// "After invocation of this method, the specified [source] store is
		// removed from the coordinator and thus no longer a useful reference."
		// => Strategy:
		// 1. Create a new "intermediate" NSPersistentStoreCoordinator and add
		//    the original store file.
		// 2. Use this new PSC to migrate to a new file URL.
		// 3. Drop all reference to the intermediate PSC.
		precondition(persistentStores.indices.contains(index), "Index \(index) doesn't exist in persistentStores array")
		let sourceStore = persistentStores[index]
		let backupCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)

		let intermediateStoreOptions = (sourceStore.options ?? [:])
			.merging([NSReadOnlyPersistentStoreOption: true],
					 uniquingKeysWith: { $1 })
		let intermediateStore = try backupCoordinator.addPersistentStore(
			ofType: sourceStore.type,
			configurationName: sourceStore.configurationName,
			at: sourceStore.url,
			options: intermediateStoreOptions
		)

		let backupStoreOptions: [AnyHashable: Any] = [
			NSReadOnlyPersistentStoreOption: true,
			// Disable write-ahead logging. Benefit: the entire store will be
			// contained in a single file. No need to handle -wal/-shm files.
			// https://developer.apple.com/library/content/qa/qa1809/_index.html
			NSSQLitePragmasOption: ["journal_mode": "DELETE"],
			// Minimize file size
			NSSQLiteManualVacuumOption: true,
			]

		// Filename format: basename-date.sqlite
		// E.g. "MyStore-20180221T200731.sqlite" (time is in UTC)
		func makeFilename() -> String {
			let basename = sourceStore.url?.deletingPathExtension().lastPathComponent ?? "store-backup"
			let dateFormatter = ISO8601DateFormatter()
			dateFormatter.formatOptions = [.withYear, .withMonth, .withDay, .withTime]
			let dateString = dateFormatter.string(from: Date())
			return "\(basename)-\(dateString).sqlite"
		}

		let backupFilename = makeFilename()
		let backupFile = try TemporaryFile(creatingTempDirectoryForFilename: backupFilename)
		try backupCoordinator.migratePersistentStore(intermediateStore, to: backupFile.fileURL, options: backupStoreOptions, withType: NSSQLiteStoreType)
		return backupFile
	}
}

// MARK: Restore

/// Based on https://github.com/atomicbird/CDMoveDemo/blob/cb4edb77a7a567e829af1973106a5314f3ad998b/CDMoveDemo/NSPersistentContainer%2Bextension.swift
/// Based on https://gist.github.com/ole/e113a716158e26c1089a1d74b468deed

extension NSPersistentContainer {
	public enum CopyPersistentStoreErrors: Error {
		case invalidDestination(String)
		case destinationError(String)
		case destinationNotRemoved(String)
		case copyStoreError(String)
		case invalidSource(String)
	}
	
	/// Restore backup persistent stores located in the directory referenced by `backupURL`.
	///
	/// **Be very careful with this**. To restore a persistent store, the current persistent store must be removed from the container. When that happens, **all currently loaded Core Data objects** will become invalid. Using them after restoring will cause your app to crash. When calling this method you **must** ensure that you do not continue to use any previously fetched managed objects or existing fetched results controllers. **If this method does not throw, that does not mean your app is safe.** You need to take extra steps to prevent crashes. The details vary depending on the nature of your app.
	/// - Parameter backupURL: A file URL containing backup copies of all currently loaded persistent stores.
	/// - Throws: `CopyPersistentStoreError` in various situations.
	/// - Returns: Nothing. If no errors are thrown, the restore is complete.
	public func restorePersistentStore(from backupURL: URL) throws -> Void {
		guard backupURL.isFileURL else {
			throw CopyPersistentStoreErrors.invalidSource("Backup URL must be a file URL")
		}
		
		guard FileManager.default.fileExists(atPath: backupURL.path) else {
			throw CopyPersistentStoreErrors.invalidSource("Missing backup store for \(backupURL.path)")
		}
		
		guard let persistentStoreDescription = persistentStoreDescriptions.first else {
			throw CopyPersistentStoreErrors.invalidDestination("Can't get current store description")
		}
		
		guard let loadedStoreURL = persistentStoreDescription.url else {
			throw CopyPersistentStoreErrors.invalidDestination("Can't get the url of current store")
		}
		
		
		do {
			let storeOptions = persistentStoreDescription.options
			let configurationName = persistentStoreDescription.configuration
			let storeType = persistentStoreDescription.type
			
			/// Replace the current store with the backup copy.
			/// This has a side effect of removing the current store from the Core Data stack.
			/// When restoring, it's necessary to use the current persistent store coordinator.
			try persistentStoreCoordinator.replacePersistentStore(
				at: loadedStoreURL,
				destinationOptions: storeOptions,
				withPersistentStoreFrom: backupURL,
				sourceOptions: storeOptions,
				ofType: storeType
			)
			
			/// Add the persistent store at the same location we've been using,
			/// because it was removed in the previous step.
			try persistentStoreCoordinator.addPersistentStore(
				ofType: storeType,
				configurationName: configurationName,
				at: loadedStoreURL,
				options: storeOptions
			)
		} catch {
			throw CopyPersistentStoreErrors.copyStoreError("Could not restore: \(error.localizedDescription)")
		}
	}
}
