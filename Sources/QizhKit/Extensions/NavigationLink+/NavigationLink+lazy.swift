//
//  NavigationLink+lazy.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 26.06.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension LazyView {
	init(escaped view: @escaping () -> Heavy) {
		self.produce = view
	}
}

public extension NavigationLink {
	
	static func lazy<Heavy>(
		destination: @autoclosure @escaping () -> Heavy,
		@ViewBuilder label: () -> Label
	) -> NavigationLink
		where
		Heavy: View,
		Destination == LazyView<Heavy>
	{
		NavigationLink(
			destination: LazyView(escaped: destination),
			label: label
		)
	}
	
	static func lazy<Heavy>(
		@ViewBuilder destination: @escaping () -> Heavy,
		isActive: Binding<Bool>,
		@ViewBuilder label: () -> Label
	) -> NavigationLink
		where
		Heavy: View,
		Destination == LazyView<Heavy>
	{
		NavigationLink(
			destination: LazyView(escaped: destination),
			isActive: isActive,
			label: label
		)
	}
	
	static func lazy<Heavy, Tag>(
		destination: @autoclosure @escaping () -> Heavy,
		tag: Tag,
		selection: Binding<Tag?>,
		@ViewBuilder label: () -> Label
	) -> NavigationLink
		where
		Heavy: View,
		Destination == LazyView<Heavy>,
		Tag: Hashable
	{
		NavigationLink(
			destination: LazyView(escaped: destination),
			tag: tag,
			selection: selection,
			label: label
		)
	}
}

public extension NavigationLink where Label == Text {
	
	static func lazy<Heavy>(_ titleKey: LocalizedStringKey, destination: @autoclosure @escaping () -> Heavy) -> NavigationLink where Heavy: View, Destination == LazyView<Heavy> {
		NavigationLink(titleKey, destination: LazyView(escaped: destination))
	}
	
	static func lazy<Heavy, S>(_ title: S, destination: @autoclosure @escaping () -> Heavy) -> NavigationLink where S: StringProtocol, Heavy: View, Destination == LazyView<Heavy> {
		NavigationLink(title, destination: LazyView(escaped: destination))
	}
	
	static func lazy<Heavy>(_ titleKey: LocalizedStringKey, destination: @autoclosure @escaping () -> Heavy, isActive: Binding<Bool>) -> NavigationLink where Heavy: View, Destination == LazyView<Heavy> {
		NavigationLink(titleKey, destination: LazyView(escaped: destination), isActive: isActive)
	}
	
	static func lazy<Heavy, S>(_ title: S, destination: @autoclosure @escaping () -> Heavy, isActive: Binding<Bool>) -> NavigationLink where S: StringProtocol, Heavy: View, Destination == LazyView<Heavy> {
		NavigationLink(title, destination: LazyView(escaped: destination), isActive: isActive)
	}
	
	static func lazy<Heavy, V>(_ titleKey: LocalizedStringKey, destination: @autoclosure @escaping () -> Heavy, tag: V, selection: Binding<V?>) -> NavigationLink where V: Hashable, Heavy: View, Destination == LazyView<Heavy> {
		NavigationLink(titleKey, destination: LazyView(escaped: destination), tag: tag, selection: selection)
	}
	
	static func lazy<Heavy, S, V>(_ title: S, destination: @autoclosure @escaping () -> Heavy, tag: V, selection: Binding<V?>) -> NavigationLink where S: StringProtocol, V: Hashable, Heavy: View, Destination == LazyView<Heavy> {
		NavigationLink(title, destination: LazyView(escaped: destination), tag: tag, selection: selection)
	}
}

public extension NavigationLink where Label == Pixel {
	static func lazy <Heavy> (
		_ destination: @autoclosure @escaping () -> Heavy
	) -> NavigationLink
		where Heavy: View, Destination == LazyView<Heavy>
	{
		NavigationLink(destination: LazyView(escaped: destination)) {
			Pixel()
		}
	}
	
	static func lazy <Heavy> (
		destination: @autoclosure @escaping () -> Heavy
	) -> NavigationLink
		where Heavy: View, Destination == LazyView<Heavy>
	{
		NavigationLink(destination: LazyView(escaped: destination)) {
			Pixel()
		}
	}
	
	static func lazy <Heavy> (
		destination: @autoclosure @escaping () -> Heavy,
		isActive: Binding<Bool>
	) -> NavigationLink
		where Heavy: View, Destination == LazyView<Heavy>
	{
		NavigationLink(destination: LazyView(escaped: destination), isActive: isActive) {
			Pixel()
		}
	}
}

/*
public extension NavigationLink where Label == Text {
	static func lazy<Heavy, S>(_ title: S, destination: @autoclosure @escaping () -> Heavy) -> NavigationLink where S: StringProtocol, Heavy: View, Destination == LazyView<Heavy> {
NavigationLink(destination: LazyView(escaped: destination), label: { Text(title) })
	}
	
	static func lazy<Heavy, S>(_ title: S, destination: @autoclosure @escaping () -> Heavy, isActive: Binding<Bool>) -> NavigationLink where S: StringProtocol, Heavy: View, Destination == LazyView<Heavy> {
NavigationLink(destination: LazyView(escaped: destination), isActive: isActive, label: { Text(title) })
	}
}
*/
