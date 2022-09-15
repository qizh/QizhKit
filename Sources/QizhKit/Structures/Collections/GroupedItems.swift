//
//  GroupedItems.swift
//  Bespokely
//
//  Created by Serhii Shevchenko on 13.05.2021.
//  Copyright © 2021 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

public struct GroupedItems <Group, Element>: Equatable
	where Group: Equatable,
		  Element: Equatable
		// Group: GroupCardDataProvidable,
{
	public let group: Group
	public let items: [Element]
	
	public init(group: Group, items: [Element]) {
		self.group = group
		self.items = items
	}
}

public extension GroupedItems where Group: Hashable {
	init(_ dictionaryElement: Dictionary<Group, [Element]>.Element) {
		group = dictionaryElement.key
		items = dictionaryElement.value
	}
	
	static func fromDictionaryElement(
		_ element: Dictionary<Group, [Element]>.Element
	) -> Self {
		.init(element)
	}
}

extension GroupedItems: Identifiable where Group: Identifiable {
	public var id: Group.ID { group.id }
}

extension Collection {
	@inlinable
	public func groupedItems<G, I>() -> [I] where Element == GroupedItems<G, I> {
		flatMap(\.items)
	}
}

// MARK: Tools

public struct GroupedItemsTools {
	/// Will set `.none` if not available in groups.
	/// Will set the updated one if items have changed.
	/// Will do nothing if nothing have changed.
	public static func update <Category, Element> (
		group binding: Binding<GroupedItems<Category, Element>?>,
		from groups: [GroupedItems<Category, Element>]
	) where Category: Identifiable {
		if let selectedGroup = binding.wrappedValue {
			if let updatedGroup = groups.first(id: selectedGroup.id) {
				if updatedGroup != selectedGroup {
					withAnimation(.spring()) {
						binding.wrappedValue = updatedGroup
					}
				}
			} else {
				withAnimation(.spring()) {
					binding.wrappedValue = .none
				}
			}
		}
	}
}
