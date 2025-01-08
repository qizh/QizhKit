//
//  Button+init.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 11.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: Selfmade

extension View {
	/// Just a function returning `self`.
	/// Useful when you need to provide
	/// a function returning `some View`
	/// where this view should be `self`
	@inlinable public func selfmade() -> Self { self }
}

// MARK: Just button

extension View {
	@inlinable public func button() -> Button<Self> {
		.init(
			action: { },
			label: selfmade
		)
	}
}

// MARK: Opening URL

extension View {
	
	/// For valid URLs converts a view to a `SafariButton` or `Link`
	/// - Parameters:
	///   - url: Won't make any change for undefined URLs
	///   - target: In app or in Safari
	///   - title: In app browser start title
	///   - isActive: In app browser `isActive`
	@ViewBuilder
	public func button(
		opening url: URL?,
		target: ButtonURLOpenTarget = .app,
		tint: Color? = .none,
		isActive: Binding<Bool>? = .none
	) -> some View {
		if let url {
			if #available(iOS 14.0, *) {
				switch target {
				case .app:
					SafariButton(
						opening: url,
						tintColor: tint,
						isActive: isActive,
						content: { self }
					)
				case .safari:
					Link(
						destination: url,
						label: { self }
					)
				}
			} else {
				SafariButton(
					opening: url,
					tintColor: tint,
					isActive: isActive,
					content: { self }
				)
			}
		} else {
			self
		}
	}
}

// MARK: > URL Open Target

public enum ButtonURLOpenTarget {
	case app
	case safari
}

// MARK: Button + Binding

extension View {
	@inlinable public func button <Value> (
		resetting binding: Binding<Value?>,
					 flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(
			action: {
				let callback = {
					binding.wrappedValue = .none
				}
				
				if flow == .current {
					callback()
				} else {
					flow.proceed(with: callback)
				}
			},
			label: { self }
		)
	}
	
	@inlinable public func button <Value> (
		assigning value: Value,
			 to binding: Binding<Value>,
				   flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(
			action: {
				let callback = {
					binding.wrappedValue = value
				}
				
				if flow == .current {
					callback()
				} else {
					flow.proceed(with: callback)
				}
			},
			label: { self }
		)
	}
	
	@inlinable public func button(
		toggling binding: Binding<Bool>,
				    flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(
			action: {
				if flow == .current {
					binding.toggle()
				} else {
					flow.proceed(with: binding.toggle)
				}
			},
			label: { self }
		)
	}
}

// MARK: View + Button

extension View {
	@inlinable public func button(
		action: @escaping () -> Void
	) -> Button<Self> {
		Button(action: action, label: selfmade)
	}
	
	@inlinable public func button(
		role: ButtonRole,
		action: @escaping () -> Void
	) -> Button<Self> {
		Button(role: role, action: action, label: selfmade)
	}
	
	@inlinable public func asyncButton(
		priority: TaskPriority? = .none,
		action: @escaping @Sendable () async -> Void
	) -> Button<Self> {
		button {
			Task(priority: priority) {
				await action()
			}
		}
	}
}

// MARK: View + Special Button

extension View {
	@inlinable public func button(copyingToClipboard text: String) -> Button<Self> {
		Button(action: { UIPasteboard.general.string = text }, label: selfmade)
	}
	
	@inlinable public func button(copyingToClipboard text: AttributedString) -> Button<Self> {
		Button(
			action: { UIPasteboard.general.setObjects(.just(NSAttributedString(text))) },
			label: selfmade
		)
	}
}


#if swift(>=5.9)

// MARK: > Variadic Generics

extension View {
	public func button <each P> (
		action: @escaping (repeat each P) -> Void,
		_ parameters: repeat each P
	) -> Button<Self> {
		Button {
			action(repeat each parameters)
		} label: {
			self
		}
	}
	
	public func asyncButton <each P: Sendable> (
		priority: TaskPriority? = .none,
		action: @escaping @Sendable (repeat each P) async -> Void,
		_ parameters: repeat each P
	) -> Button<Self> {
		Button {
			Task(priority: priority) {
				await action(repeat each parameters)
			}
		} label: {
			self
		}
	}
	
	public func asyncButton <each P: Sendable> (
		role: ButtonRole,
		priority: TaskPriority? = .none,
		action: @escaping @Sendable (repeat each P) async -> Void,
		_ parameters: repeat each P
	) -> Button<Self> {
		Button(role: role) {
			Task(priority: priority) {
				await action(repeat each parameters)
			}
		} label: {
			self
		}
	}
	
	public func button <each P> (
		role: ButtonRole,
		action: @escaping (repeat each P) -> Void,
		_ parameters: repeat each P
	) -> Button<Self> {
		Button(role: role) {
			action(repeat each parameters)
		} label: {
			self
		}
	}
}

#else

// MARK: > Outdated

extension View {
	@inlinable public func button <A> (
		action: @escaping (A) -> Void,
		_ argument: A
	) -> Button<Self> {
		button {
			action(argument)
		}
	}
	
	@inlinable public func button <A1, A2> (
		action: @escaping (A1, A2) -> Void,
		_ argument1: A1,
		_ argument2: A2
	) -> Button<Self> {
		button {
			action(argument1, argument2)
		}
	}
	
	@inlinable public func button <A1, A2, A3> (
		action: @escaping (A1, A2, A3) -> Void,
		_ argument1: A1,
		_ argument2: A2,
		_ argument3: A3
	) -> Button<Self> {
		button {
			action(argument1, argument2, argument3)
		}
	}
}

extension View {
	@inlinable public func button <A> (
		role: ButtonRole,
		action: @escaping (A) -> Void,
		_ argument: A
	) -> Button<Self> {
		button(role: role) {
			action(argument)
		}
	}
	
	@inlinable public func button <A1, A2> (
		role: ButtonRole,
		action: @escaping (A1, A2) -> Void,
		_ argument1: A1,
		_ argument2: A2
	) -> Button<Self> {
		button(role: role) {
			action(argument1, argument2)
		}
	}
	
	@inlinable public func button <A1, A2, A3> (
		role: ButtonRole,
		action: @escaping (A1, A2, A3) -> Void,
		_ argument1: A1,
		_ argument2: A2,
		_ argument3: A3
	) -> Button<Self> {
		button(role: role) {
			action(argument1, argument2, argument3)
		}
	}
}

extension View {
	@inlinable public func asyncButton <A> (
		priority: TaskPriority? = .none,
		action: @escaping @Sendable (A) async -> Void,
		_ argument: A
	) -> Button<Self> {
		button {
			Task(priority: priority) {
				await action(argument)
			}
		}
	}
	
	@inlinable public func asyncButton <A1, A2> (
		priority: TaskPriority? = .none,
		action: @escaping @Sendable (A1, A2) async -> Void,
		_ argument1: A1,
		_ argument2: A2
	) -> Button<Self> {
		button {
			Task(priority: priority) {
				await action(argument1, argument2)
			}
		}
	}
	
	@inlinable public func asyncButton <A1, A2, A3> (
		priority: TaskPriority? = .none,
		action: @escaping @Sendable (A1, A2, A3) async -> Void,
		_ argument1: A1,
		_ argument2: A2,
		_ argument3: A3
	) -> Button<Self> {
		button {
			Task(priority: priority) {
				await action(argument1, argument2, argument3)
			}
		}
	}
}

extension View {
	@inlinable public func asyncButton <A> (
		role: ButtonRole,
		priority: TaskPriority? = .none,
		action: @escaping @Sendable (A) async -> Void,
		_ argument: A
	) -> Button<Self> {
		button(role: role) {
			Task(priority: priority) {
				await action(argument)
			}
		}
	}
	
	@inlinable public func asyncButton <A1, A2> (
		role: ButtonRole,
		priority: TaskPriority? = .none,
		action: @escaping @Sendable (A1, A2) async -> Void,
		_ argument1: A1,
		_ argument2: A2
	) -> Button<Self> {
		button(role: role) {
			Task(priority: priority) {
				await action(argument1, argument2)
			}
		}
	}
	
	@inlinable public func asyncButton <A1, A2, A3> (
		role: ButtonRole,
		priority: TaskPriority? = .none,
		action: @escaping @Sendable (A1, A2, A3) async -> Void,
		_ argument1: A1,
		_ argument2: A2,
		_ argument3: A3
	) -> Button<Self> {
		button(role: role) {
			Task(priority: priority) {
				await action(argument1, argument2, argument3)
			}
		}
	}
}

#endif

// MARK: - Tests

/*
fileprivate func a2(a: Int, b: String) { }
fileprivate func a0() { }
fileprivate let a = Text(String(""))
	.button()
	.button(action: a0)
	.button(action: a2, 1, "")
*/

// MARK: - Outdated & Deprecated -



// MARK: View + button + animation

extension View {
	@available(*, deprecated, message: "Just use the `withAnimation { ... }` action")
	@inlinable public func button(
		action: @escaping () -> Void,
		animation: Animation
	) -> Button<Self> {
		Button(action: animating(action, with: animation), label: { self })
	}

	@available(*, deprecated, message: "Just use the `withAnimation { ... }` action")
	@inlinable public func button(
		animation: Animation,
		action: @escaping () -> Void
	) -> Button<Self> {
		Button(action: animating(action, with: animation), label: { self })
	}
}

// MARK: View + button

extension View {
	@available(*, deprecated, renamed: "button(resetting:flow:)", message: "Animation can be added to Binding, `flow` parameter should be named")
	@inlinable public func button <Value> (
		resetting binding: Binding<Value?>,
				animation: Animation? = .none,
				   _ flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(
			action: {
				flow.proceed {
					if let animation = animation {
						withAnimation(animation) {
							binding.wrappedValue = .none
						}
					} else {
						binding.wrappedValue = .none
					}
				}
			},
			label: { self }
		)
	}
	
	@_disfavoredOverload
	@available(*, deprecated, renamed: "button(assigning:to:flow:)", message: "Animation can be added to Binding, `flow` parameter should be named")
	@inlinable public func button <Value> (
		assigning value: Value,
			 to binding: Binding<Value>,
			  animation: Animation? = .none,
				 _ flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(
			action: {
				flow.proceed {
					if let animation {
						withAnimation(animation) {
							binding.wrappedValue = value
						}
					} else {
						binding.wrappedValue = value
					}
				}
			},
			label: { self }
		)
	}
	
	@_disfavoredOverload
	@available(*, deprecated, renamed: "button(toggling:flow:)", message: "Animation can be added to Binding, `flow` parameter should be named")
	@inlinable public func button(
		toggling binding: Binding<Bool>,
			   animation: Animation? = .none,
				  _ flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(
			action: {
				flow.proceed {
					if let animation {
						withAnimation(animation) {
							binding.toggle()
						}
					} else {
						binding.toggle()
					}
				}
			},
			label: { self }
		)
	}
}

// MARK: View + button + Navigation

extension View {
	/// - Warning: Deprecated. This method is using `NavigationLink`, which is outdated
	// @available(*, deprecated, message: "This method is using `NavigationLink`, which is outdated")
	@inlinable public func button <Screen: View> (
		showing screen: Screen
	) -> some View {
		NavigationLink(
			destination: screen,
			label: { self }
		)
	}
	
	/*
	/// - Warning: Deprecated. This method is using `NavigationLink`, which is outdated
	@available(*, deprecated, message: "This method is using `NavigationLink`, which is outdated")
	@inlinable public func button <Screen: View> (
		showing screen: Screen,
		isActive: Binding<Bool>
	) -> some View {
		NavigationLink(
			destination: screen,
			isActive: isActive,
			label: { self }
		)
	}
	*/
}

/*
// MARK: Action

public protocol ExecutableAction {
	func execute()
}

public struct Action {
	public struct DoNothing: ExecutableAction {
		public func execute() { }
	}
	
	public struct Assign<Value, Root>: ExecutableAction {
		public typealias Key = ReferenceWritableKeyPath<Root, Value>
		
		private let value: Value
		private let keyPath: Key
		private let object: Root

		public init(_ value: Value, to keyPath: Key, on object: Root) {
			self.value = value
			self.keyPath = keyPath
			self.object = object
		}
		
		public func execute() {
			object[keyPath: keyPath] = value
		}
	}
	
	/*
	public struct Callback: ExecutableAction {
		
	}
	*/
	
	/*
	public struct PresentationDismiss: ExecutableAction {
		
	}
	*/
}

public extension ExecutableAction {
	static var doNothing: ExecutableAction { Action.DoNothing() }
	static func assign<Value, Root>(
		   _ value: Value,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		 on object: Root
	)
		-> ExecutableAction
	{
		Action.Assign(value, to: keyPath, on: object)
	}
}
*/
