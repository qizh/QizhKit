//
//  View+animate.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 30.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI

extension View {
	@inlinable
	public func animate <Value: Equatable> (
		using anim: Animation = .easeInOut(duration: 0.3),
		updating value: Value,
		_ action: @escaping @Sendable () -> Void
	) -> some View {
		animation(anim, value: value)
		.onAppear {
			execute {
				action()
			}
		}
		/*
        whenAppear {
			execute {
				withAnimation(animation, action)
			}
        }
		*/
    }
	
	#if swift(<6.0)
	@inlinable
	public func animate <Value: Equatable, Root>(
//		assigning value: @escaping @autoclosure () -> Value,
		assigning value: Value,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		on object: Root,
		using anim: Animation = .easeInOut(duration: 0.3)
	) -> some View {
		animation(
			anim,
			value: value
		)
		.onAppear {
			execute {
				object[keyPath: keyPath] = value
			}
		}
    }
	
	@inlinable
	public func animateForever <Value: Equatable> (
		using anim: Animation = Animation.easeInOut(duration: 0.3),
		autoreverses: Bool = false,
		updating value: Value,
		_ action: @escaping () -> Void
	) -> some View {
		animation(
			anim.repeatForever(autoreverses: autoreverses),
			value: value
		)
		.onAppear {
			execute {
				action()
			}
		}
		/*
        whenAppear {
			execute {
				withAnimation(
					animation.repeatForever(autoreverses: autoreverses),
					action
				)
			}
        }
		*/
    }
	
	@inlinable
	public func animateForever <Value: Equatable, Root> (
//		assigning value: @escaping @autoclosure () -> Value,
		assigning value: Value,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		on object: Root,
		using anim: Animation = .linear(duration: 1),
		autoreverses: Bool = false
	) -> some View {
		animation(
			anim.repeatForever(autoreverses: autoreverses),
			value: value
		)
		.onAppear {
			execute {
				object[keyPath: keyPath] = value
			}
		}
	}
	#endif
	
	@inlinable
	public func animateForever <Value: Equatable> (
		assigning value: Value,
		to binding: Binding<Value>,
		using anim: Animation = .linear(duration: 1),
		autoreverses: Bool = false
	) -> some View {
		animation(
			anim.repeatForever(autoreverses: autoreverses),
			value: value
		)
		.onAppear {
			binding.wrappedValue = value
		}
	}
}

extension Animation {
	public func `repeat`(
		while expression: Bool,
		autoreverses: Bool = true
	) -> Animation {
		expression
		? self.repeatForever(autoreverses: autoreverses)
		: self
	}
}

// MARK: Combine Transitions

extension View {
	@_disfavoredOverload
	@ViewBuilder
	public func transition(_ transitions: AnyTransition...) -> some View {
		// transition(transitions.combined() ?? .identity)
		if let combination = transitions.combined() {
			self.transition(combination)
		} else {
			self
		}
	}
}

extension AnyTransition {
	public static func + (lhs: AnyTransition, rhs: AnyTransition) -> AnyTransition {
		lhs.combined(with: rhs)
	}
}

extension RangeReplaceableCollection where Element == AnyTransition {
	public func combined() -> AnyTransition? {
		if let base = first {
			self.dropFirst().reduce(base, +)
		} else {
			.none
		}
	}
}
