//
//  CollectionSafeIndex.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 06.10.2019.
//  Copyright © 2019 Serhii Shevchenko. All rights reserved.
//

import Foundation

public extension Collection {
    subscript (safe index: Index) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
