//
//  CollectionSafeIndex.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 06.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Foundation

extension Collection {
	public subscript(safe index: Index) -> Element? {
		if indices.contains(index) {
			self[index]
		} else {
			nil
		}
	}
}

extension Collection {
	public subscript<Wrapped>(safe index: Index) -> Wrapped? where Element == Wrapped? {
		if indices.contains(index) {
			self[index]
		} else {
			nil
		}
	}
}
