//
//  CancellableStore.swift
//  BespokelyKit
//
//  Created by Serhii Shevchenko on 16.06.2025.
//

import Foundation
import Combine

public actor CancellableStore {
	/// Shared instance if you want a global bucket.
	public static let shared = CancellableStore()

	public var set = Set<AnyCancellable>()

	/// Add a token.
	public func add(_ c: AnyCancellable) {
		set.insert(c)
	}

	/// Cancel-and-clear all tokens.
	public func cancelAll() {
		for c in set { c.cancel() }
		set.removeAll()
	}
}

extension AnyCancellable: @retroactive @unchecked Sendable {
	/// Store into an actor-backed store.
	public func store(in store: CancellableStore = .shared) {
		// fire-and-forget the add call
		Task { await store.add(self) }
	}
}
