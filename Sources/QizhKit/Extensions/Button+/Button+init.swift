//
//  Button+init.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 11.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

// MARK: No Action

public extension Button where Label == Text {
	/// A button with no action
	/// - Parameter label: label producing view builder closure
	@inlinable init(@ViewBuilder label: () -> Label) {
		self.init(action: {}, label: label)
	}
	
	/// A button with a text label with no action
	/// - Parameter title: Title of the button
	@inlinable @_disfavoredOverload
	init<S>(_ title: S) where S: StringProtocol {
		self.init(title, action: {})
	}
	
	/// A button with a text label with no action
	@inlinable
	init(_ title: LocalizedStringKey) {
		self.init(title, action: {})
	}
}

// MARK: Assign

public extension Button where Label == Text {
	/// A button with a text label assigning a value to a variable on tap.
	/// So you don't need write any action callback.
	/// A common case. Similar to a `Combine` `assign` method.
	/// - Parameters:
	///   - title: Title of the button.
	///   - value: A value to assign on tap. Or I would say an expression
	///   that produces a value to assign.
	///   `isPresentingView.toggled` would be a good example
	///   - keyPath: A keypath to a variable. For example, `\.isPresentingView`.
	///   - object: Root of a keypath. Usually, `self`.
	///   Check [a general initializer](x-source-tag://Button.assignValue)
	///   if you want to build another than just text label.
	/// - Tag: Button.TextLabel.assignValue
	@inlinable init<S: StringProtocol, Value, Root>(
		_ title: S,
		assign value: Value,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		on object: Root,
		animation: Animation? = .none,
		_ flow: ExecutionFlow = .current
	) {
		self.init(
			title,
			action: {
				flow.proceed {
					if let animation = animation {
						withAnimation(animation) {
							object[keyPath: keyPath] = value
						}
					} else {
						object[keyPath: keyPath] = value
					}
				}
			}
		)
	}
}

public extension Button {
	/// A button, assigning a value to a variable on tap.
	/// So you don't need write any action callback.
	/// A common case. Similar to a `Combine` `assign` method.
	/// - Parameters:
	///   - value: A value to assign on tap. Or I would say an expression
	///   that produces a value to assign.
	///   `isPresentingView.toggled` would be a good example
	///   - keyPath: A keypath to a variable. For example, `\.isPresentingView`.
	///   - object: Root of a keypath. Usually, `self`.
	///   - label: `@ViewBuilder` closure producing a button label.
	///   Check [this initializer](x-source-tag://Button.TextLabel.assignValue)
	///   if you just need a text label.
	/// - Tag: Button.assignValue
	@inlinable init<Value, Root>(
		assign value: Value,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		on object: Root,
		animation: Animation? = .none,
		@ViewBuilder label: () -> Label,
		_ flow: ExecutionFlow = .current
	) {
		self.init(
			action: {
				flow.proceed {
					if let animation = animation {
						withAnimation(animation) {
							object[keyPath: keyPath] = value
						}
					} else {
						object[keyPath: keyPath] = value
					}
				}
			},
			label: label
		)
	}
}

public extension Button {
	/// Creates a Button with no action for quick preview purposes
	@inlinable init(@ViewBuilder label: () -> Label) {
		self.init(action: {}, label: label)
	}
}

// MARK: Pixel

public extension Button where Label == Pixel {
	/// Crates a button with a non EmptyView invisible label.
	/// Use to add an action for List row
	@inlinable static func Pixel(action: @escaping () -> Void) -> Button {
		Button(action: action, label: Label.init)
	}
}

// MARK: Button > Bodybuilder

public protocol Bodybuilder: View { }
public extension Bodybuilder {
	/// A function that returns a `View`'s `body`.
	/// Convenient when you need to pass a view to a `@ViewBuilder`
	/// ```
	/// Button(action: action, label: bodybuilder)
	/// ```
	@inlinable func bodybuilder() -> Body { body }
}

public extension Bodybuilder {
	/// Converts a view to a button with no action
	/// - Returns: a Button view
	@inlinable func button() -> Button<Body> { Button(label: bodybuilder) }
	
	/// Converts a view to a button with action
	/// - Returns: a Button view
	@inlinable func button(action: @escaping () -> Void) -> Button<Body> { Button(action: action, label: bodybuilder) }
	@inlinable func button<Value, Root> (
		assigning value: Value,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		on object: Root,
		animation: Animation? = .none
	) -> Button<Body> {
		Button(assign: value, to: keyPath, on: object, animation: animation, label: bodybuilder)
	}
}

// MARK: Button > Initializable

public extension View where Self: Initializable {
	@inlinable func button() -> Button<Self> { Button(label: Self.init) }
	@inlinable func button(action: @escaping () -> Void) -> Button<Self> { Button(action: action, label: Self.init) }
	@inlinable func button<Value, Root> (
		assigning value: Value,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		on object: Root,
		animation: Animation? = .none,
		_ flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(
			   assign: value,
			       to: keyPath,
			       on: object,
			animation: animation,
			    label: Self.init,
			           flow
		)
	}
}

// MARK: iOS 15

#if swift(>=5.5)
@available(iOS 15.0, *)
extension View {
	@inlinable
	public func button(
		role: ButtonRole,
		action: @escaping () -> Void
	) -> Button<Self> {
		Button(role: role, action: action, label: selfmade)
	}
	
	@inlinable
	public func button <A> (
		role: ButtonRole,
		action: @escaping (A) -> Void,
		_ argument: A
	) -> Button<Self> {
		Button(role: role, action: { action(argument) }, label: selfmade)
	}
	
	@inlinable
	public func button <A1, A2> (
		role: ButtonRole,
		action: @escaping (A1, A2) -> Void,
		_ argument1: A1,
		_ argument2: A2
	) -> Button<Self> {
		Button(role: role, action: { action(argument1, argument2) }, label: selfmade)
	}
}
#endif

// MARK: Button > Selfmade | fallback

public extension View {
	@inlinable func selfmade() -> Self { self } // homemade?
	@inlinable func button() -> Button<Self> { Button(label: selfmade) }
	
	@inlinable
	func asyncButton(
		priority: TaskPriority? = .none,
		action: @escaping () async -> Void
	) -> Button<Self> {
		button {
			Task(priority: priority) {
				await action()
			}
		}
	}
	
	@inlinable
	func asyncButton <A> (
		priority: TaskPriority? = .none,
		action: @escaping (A) async -> Void,
		_ argument: A
	) -> Button<Self> {
		button {
			Task(priority: priority) {
				await action(argument)
			}
		}
	}
	
	@inlinable
	func asyncButton <A1, A2> (
		priority: TaskPriority? = .none,
		action: @escaping (A1, A2) async -> Void,
		_ argument1: A1,
		_ argument2: A2
	) -> Button<Self> {
		button {
			Task(priority: priority) {
				await action(argument1, argument2)
			}
		}
	}
	
	@inlinable
	func button(
		action: @escaping () -> Void
	) -> Button<Self> {
		Button(action: action, label: selfmade)
	}
	
	@inlinable
	func button <A> (
		action: @escaping (A) -> Void,
		_ argument: A
	) -> Button<Self> {
		Button(action: { action(argument) }, label: selfmade)
	}
	
	@inlinable
	func button <A1, A2> (
		action: @escaping (A1, A2) -> Void,
		_ argument1: A1,
		_ argument2: A2
	) -> Button<Self> {
		Button(action: { action(argument1, argument2) }, label: selfmade)
	}
	
	@inlinable
	func button(
		action: @escaping () -> Void,
		animation: Animation
	) -> Button<Self> {
		Button(action: animating(action, with: animation), label: selfmade)
	}
	
	@inlinable
	func button(
		animation: Animation,
		action: @escaping () -> Void
	) -> Button<Self> {
		Button(action: animating(action, with: animation), label: selfmade)
	}
	
	@inlinable
	func button<Value, Root> (
		assigning value: Value,
			 to keyPath: ReferenceWritableKeyPath<Root, Value>,
		      on object: Root,
		      animation: Animation? = .none,
		         _ flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(assign: value,
			       to: keyPath,
			       on: object,
			animation: animation,
			    label: selfmade,
			           flow)
	}
	
	@inlinable
	func button <Value> (
		assigning value: Value,
			 to binding: Binding<Value>,
			  animation: Animation? = .none,
				 _ flow: ExecutionFlow = .current
	) -> Button<Self> {
		.init(
			action: {
				flow.proceed {
					if let animation = animation {
						withAnimation(animation) {
							binding.wrappedValue = value
						}
					} else {
						binding.wrappedValue = value
					}
				}
			},
			label: selfmade
		)
	}
	
	@inlinable
	func button(
		toggling binding: Binding<Bool>,
		       animation: Animation? = .none,
			      _ flow: ExecutionFlow = .current
	) -> Button<Self> {
		.init(
			action: {
				flow.proceed {
					if let animation = animation {
						withAnimation(animation) {
							binding.toggle()
						}
					} else {
						binding.toggle()
					}
				}
			},
			label: selfmade
		)
	}
	
	@inlinable
	func button<Value, Root> (
		resetting keyPath: ReferenceWritableKeyPath<Root, Value?>,
			    on object: Root,
			    animation: Animation? = .none,
				   _ flow: ExecutionFlow = .current
	) -> Button<Self> {
		Button(assign: .none,
				   to: keyPath,
				   on: object,
			animation: animation,
				label: selfmade,
					   flow)
	}
	
	@inlinable
	func button <Value> (
		resetting binding: Binding<Value?>,
				animation: Animation? = .none,
				   _ flow: ExecutionFlow = .current
	) -> Button<Self> {
		.init(
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
			label: selfmade
		)
	}
	
	/// For valid URLs converts a view to a `SafariButton` or `Link`
	/// - Parameters:
	///   - url: Won't make any change for undefined URLs
	///   - target: In app or in Safari
	///   - title: In app browser start title
	///   - isActive: In app browser `isActive`
	@ViewBuilder
	func button(
		opening url: URL?,
		target: URLOpenTarget = .app,
		isActive: Binding<Bool>? = .none
	) -> some View {
		if let url = url {
			if #available(iOS 14.0, *) {
				switch target {
				case .app:
					SafariButton(
						opening: url,
						isActive: isActive,
						content: selfmade
					)
				case .safari:
					Link(
						destination: url,
						label: selfmade
					)
				}
			} else {
				SafariButton(
					opening: url,
					isActive: isActive,
					content: selfmade
				)
			}
		} else {
			self
		}
	}
	
	func button <Screen: View> (
		showing screen: Screen
	) -> some View {
		NavigationLink(
			destination: screen,
			label: selfmade
		)
	}
	
	func button <Screen: View> (
		showing screen: Screen,
		isActive: Binding<Bool>
	) -> some View {
		NavigationLink(
			destination: screen,
			isActive: isActive,
			label: selfmade
		)
	}
}

public enum URLOpenTarget {
	case app
	case safari
}

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
