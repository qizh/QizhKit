//
//  View+onReceive.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 24.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine

// MARK: onChange

extension View {
	@_disfavoredOverload
	@inlinable public func onChange <Value: Equatable> (
		of value: Value,
		perform action: @escaping () -> Void
	) -> some View {
		onChange(
			of: value,
			perform: { _ in action() }
		)
	}
}

// MARK: onReceive

extension View {
	@inlinable public func onReceive<P>(
		_ publisher: P,
		perform action: @escaping () -> Void
	) -> some View
		where
			P: Publisher,
			P.Failure == Never
	{
		onReceive(
			publisher,
			perform: { _ in
				action()
			}
		)
	}
	
	@inlinable public func onReceiveDefined<OptionalValuePublisher, Value>(
		_ publisher: OptionalValuePublisher,
		perform action: @escaping @Sendable (Value) -> Void,
		flow: ExecutionFlow = .current
	) -> some View where OptionalValuePublisher: Publisher,
						 OptionalValuePublisher.Output == Value?,
						 OptionalValuePublisher.Failure == Never,
						 Value: Sendable
	{
		onReceive(publisher) { optionalValue in
			optionalValue.map { value in
				flow.proceed(with: action, value)
			}
		}
	}
	
	@inlinable public func onReceiveDefined<OptionalValuePublisher, Value>(
		_ publisher: OptionalValuePublisher,
		perform action: @escaping @Sendable () -> Void,
		flow: ExecutionFlow = .current
	) -> some View where OptionalValuePublisher: Publisher,
						 OptionalValuePublisher.Output == Value?,
						 OptionalValuePublisher.Failure == Never
	{
		onReceive(publisher) { optionalValue in
			optionalValue.map { _ in
				flow.proceed(with: action)
			}
		}
	}
	
	@inlinable public func onReceiveValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping @Sendable (Value) -> Void,
		flow: ExecutionFlow = .current
	) -> some View where StatePublisher: Publisher,
						 StatePublisher.Output == BackendFetchState<Value>,
						 StatePublisher.Failure == Never,
						 Value: Sendable
	{
		onReceive(publisher) { state in
			state.value.map { value in
				flow.proceed(with: action, value)
			}
		}
	}
	
	public func onReceiveFirstValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping @Sendable (Value.Element) -> Void,
		_ flow: ExecutionFlow = .current
	) -> some View where Value: Collection,
						 Value.Element: Sendable,
						 StatePublisher: Publisher,
						 StatePublisher.Output == BackendFetchState<Value>,
						 StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			state.first.map { first in
				flow.proceed(with: action, first)
			}
		}
	}
	
	public func onReceiveFirstValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping @Sendable () -> Void,
		_ flow: ExecutionFlow = .current
	) -> some View
		where
		Value: Collection,
		StatePublisher: Publisher,
		StatePublisher.Output == BackendFetchState<Value>,
		StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			state.first.map { _ in
				flow.proceed(with: action)
			}
		}
	}
	
	// MARK: Assign
	
	#if swift(<6.0)
//	@inlinable
	public func assign<NonFailingPublisher, Root, Value>(
		   _ publisher: NonFailingPublisher,
		    to keyPath: ReferenceWritableKeyPath<Root, Value>,
		     on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
//		        _ flow: ExecutionFlow = .current
	) -> some View
		where
		NonFailingPublisher: Publisher,
		NonFailingPublisher.Output == Value,
		NonFailingPublisher.Failure == Never
	{
		onReceive(publisher) { value in
			guard condition else { return }
			execute {
				withAnimation(animation) {
					object[keyPath: keyPath] = value
				}
			}
		}
	}
	
//	@inlinable
	public func assign<NonFailingPublisher, Root, Value>(
		   _ publisher: NonFailingPublisher,
		    to keyPath: ReferenceWritableKeyPath<Root, Value?>,
		     on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
		NonFailingPublisher: Publisher,
		NonFailingPublisher.Output == Value,
		NonFailingPublisher.Failure == Never
	{
		onReceive(publisher) { value in
			guard condition else { return }
			execute {
				withAnimation(animation) {
					object[keyPath: keyPath] = value
				}
			}
		}
	}
	
//	@inlinable
	public func assignValue<StatePublisher, Value, Root>(
		_ publisher: StatePublisher,
		to keyPath: ReferenceWritableKeyPath<Root, Value>,
		on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
		StatePublisher: Publisher,
		StatePublisher.Output == BackendFetchState<Value>,
		StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			guard condition else { return }
			state.value.map { value in
				var action: () -> Void = { object[keyPath: keyPath] = value }
				if let animation = animation {
					action = { withAnimation(animation, action) }
				}
				execute(action)
			}
		}
	}
	
//	@inlinable
	public func assignValue<StatePublisher, Value, Root>(
		_ publisher: StatePublisher,
		to keyPath: ReferenceWritableKeyPath<Root, Value?>,
		on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
		StatePublisher: Publisher,
		StatePublisher.Output == BackendFetchState<Value>,
		StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			guard condition else { return }
			state.value.map { value in
				var action: () -> Void = { object[keyPath: keyPath] = value }
				if let animation = animation {
					action = { withAnimation(animation, action) }
				}
				execute(action)
			}
		}
	}
	
//	@inlinable
	public func assignFirstValue<StatePublisher, Value, Root>(
		_ publisher: StatePublisher,
		to keyPath: ReferenceWritableKeyPath<Root, Value.Element>,
		on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
			StatePublisher: Publisher,
			StatePublisher.Output == BackendFetchState<Value>,
			StatePublisher.Failure == Never,
			Value: Collection
	{
		onReceive(publisher) { state in
			guard condition else { return }
			state.first.map { value in
				var action: () -> Void = { object[keyPath: keyPath] = value }
				if let animation = animation {
					action = { withAnimation(animation, action) }
				}
				execute(action)
			}
		}
	}
	
//	@inlinable
	public func assignFirstValue<StatePublisher, Value, Root>(
		_ publisher: StatePublisher,
		to keyPath: ReferenceWritableKeyPath<Root, Value.Element?>,
		on object: Root,
		when condition: Bool = true,
		with animation: Animation? = .none
	) -> some View
		where
			StatePublisher: Publisher,
			StatePublisher.Output == BackendFetchState<Value>,
			StatePublisher.Failure == Never,
			Value: Collection
	{
		onReceive(publisher) { state in
			guard condition else { return }
			state.first.map { value in
				var action: () -> Void = { object[keyPath: keyPath] = value }
				if let animation = animation {
					action = { withAnimation(animation, action) }
				}
				execute(action)
			}
		}
	}
	#endif
	
	// MARK: Assign Binding
	
	public func assign <P, Value> (
		   _ publisher: P,
			to binding: Binding<Value>,
		when condition: Bool = true,
		with animation: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View where P: Publisher,
						 P.Output == Value,
						 P.Failure == Never,
						 Value: Sendable
	{
		onReceive(publisher) { value in
			guard condition else { return }
			
			let closure: @Sendable () -> Void = {
				binding.wrappedValue = value
			}
			
			flow.proceed {
				if let animation {
					withAnimation(animation) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	public func assign <P, Value> (
		   _ publisher: P,
			to binding: Binding<Value?>,
		when condition: Bool = true,
		with animation: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View where P: Publisher,
						 P.Output == Value,
						 P.Failure == Never,
						 Value: Sendable
	{
		onReceive(publisher) { value in
			guard condition else { return }
			
			let closure: @Sendable () -> Void = {
				binding.wrappedValue = value
			}
			
			flow.proceed {
				if let animation {
					withAnimation(animation) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}

	// MARK: on (Dis) Appear
	
	@ViewBuilder
	public func whenAppear(
		perform action: (() -> Void)? = nil
	) -> some View {
		switch action {
		case .none: self
		case .some(let action): self.onAppear(perform: action)
		}
	}
	
	@ViewBuilder
	public func whenAppear(
		if condition: Bool,
		perform action: (() -> Void)? = nil
	) -> some View {
		if condition {
			onAppear(perform: action)
		} else {
			self
		}
	}
	
	@inlinable public func whenAppear(
		perform action: @escaping @Sendable @MainActor () -> Void,
		in ms: Int
	) -> some View {
		onAppear {
			execute(in: ms, action)
		}
	}
	
	@inlinable public func whenAppear(
		in ms: Int,
		_ action: @escaping @Sendable @MainActor () -> Void
	) -> some View {
		onAppear {
			execute(in: ms, action)
		}
	}
	
	@inlinable public func onDisappear(
		in ms: Int,
		_ action: @escaping @Sendable @MainActor () -> Void
	) -> some View {
		onDisappear {
			execute(in: ms, action)
		}
	}
	
	#if swift(<6.0)
	@inlinable public func whenAppear <Value, Root> (
		when cond: Bool = true,
	  assign  val: @autoclosure @escaping () -> Value,
		  to  key: ReferenceWritableKeyPath<Root, Value>,
		  on root: Root,
		with anim: Animation? = .none,
			 flow: ExecutionFlow = .current
	) -> some View {
		onAppear {
			guard cond else { return }
			var exe: () -> Void = { root[keyPath: key] = val() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
			
			/*
			guard condition else { return }
			
			let assignment = {
				root[keyPath: key] = value()
			}
			
			switch (animation, ms) {
			case (.none, let ms) where ms <= 0:
				execute(assignment)
			case (.none, let ms):
				execute(in: ms, assignment)
			case (.some(let animation), let ms) where ms <= 0:
				execute {
					withAnimation(animation, assignment)
				}
			case (.some(let animation), let ms):
				execute(in: ms) {
					withAnimation(animation, assignment)
				}
			}
			*/
		}
	}
	#endif
	
	public func whenAppear <Value> (
		when condition: Bool = true,
		assign   value: @autoclosure @escaping @Sendable () -> Value,
		  to    target: Binding<Value>,
		with animation: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View where Value: Sendable {
		onAppear {
			guard condition else { return }
			
			let closure: @Sendable () -> Void = {
				target.wrappedValue = value()
			}
			
			flow.proceed {
				if let animation {
					withAnimation(animation) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	public func onAppear <Value> (
		when condition: Bool = true,
	  assign     value: @autoclosure @escaping @Sendable () -> Value?,
		  to    target: Binding<Value>,
		with animation: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View where Value: Sendable {
		onAppear {
			guard condition else { return }
			
			let closure: @Sendable () -> Void = {
				if let value = value() {
					target.wrappedValue = value
				}
			}
			
			flow.proceed {
				if let animation {
					withAnimation(animation) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	#if swift(<6.0)
	public func onDisappear <Value, Root> (
		  when cond: Bool = true,
		assign  val: @autoclosure @escaping @Sendable () -> Value,
			to  key: ReferenceWritableKeyPath<Root, Value>,
		    on root: Root,
		  with anim: Animation? = .none,
		       flow: ExecutionFlow = .current
	) -> some View where Value: Sendable {
		onDisappear {
			guard cond else { return }
			var exe: () -> Void = { root[keyPath: key] = val() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
	#endif
	
	// MARK: > Assign Binding
	
	public func onAppear <Value> (
		  when cond: Bool = true,
		assign  val: @autoclosure @escaping @Sendable () -> Value,
		 to binding: Binding<Value>,
		  with anim: Animation? = .none,
			   flow: ExecutionFlow = .current
	) -> some View where Value: Sendable {
		onAppear {
			guard cond else { return }
			
			let closure: @Sendable () -> Void = {
				binding.wrappedValue = val()
			}
			
			flow.proceed {
				if let anim {
					withAnimation(anim) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	public func onDisappear <Value> (
		  when cond: Bool = true,
		assign  val: @autoclosure @escaping @Sendable () -> Value,
		 to binding: Binding<Value>,
		  with anim: Animation? = .none,
			   flow: ExecutionFlow = .current
	) -> some View where Value: Sendable {
		onDisappear {
			guard cond else { return }
			
			let closure: @Sendable () -> Void = {
				binding.wrappedValue = val()
			}
			
			flow.proceed {
				if let anim {
					withAnimation(anim) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	// MARK: > Reset Binding<Optional>
	
	public func onAppear <Value> (
			when cond: Bool = true,
		reset binding: Binding<Value?>,
			with anim: Animation? = .none,
				 flow: ExecutionFlow = .current
	) -> some View where Value: Sendable {
		onAppear {
			guard cond else { return }
			
			let closure: @Sendable () -> Void = {
				binding.wrappedValue = .none
			}
			
			flow.proceed {
				if let anim {
					withAnimation(anim) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	public func onDisappear <Value> (
		    when cond: Bool = true,
		reset binding: Binding<Value?>,
		    with anim: Animation? = .none,
			     flow: ExecutionFlow = .current
	) -> some View where Value: Sendable {
		onDisappear {
			guard cond else { return }
			
			let closure: @Sendable () -> Void = {
				binding.wrappedValue = .none
			}
			
			flow.proceed {
				if let anim {
					withAnimation(anim) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	// MARK: > Toggle Binding<Bool>
	
	public func onAppear(
			 when cond: Bool = true,
		toggle binding: Binding<Bool>,
			 with anim: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View {
		onAppear {
			guard cond else { return }
			
			let closure: @Sendable () -> Void = {
				binding.toggle()
			}
			
			flow.proceed {
				if let anim {
					withAnimation(anim) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	public func onDisappear(
			 when cond: Bool = true,
		toggle binding: Binding<Bool>,
			 with anim: Animation? = .none,
				  flow: ExecutionFlow = .current
	) -> some View {
		onDisappear {
			guard cond else { return }
			
			let closure: @Sendable () -> Void = {
				binding.toggle()
			}
			
			flow.proceed {
				if let anim {
					withAnimation(anim) {
						closure()
					}
				} else {
					closure()
				}
			}
		}
	}
	
	// MARK: Print
	
	public func onAppear(print message: String) -> some View {
		onAppear(perform: {
			print(message)
		})
	}
	
	public func onDisappear(print message: String) -> some View {
		onDisappear(perform: {
			print(message)
		})
	}
}

/*
//@available(iOS 14.0, *)
public struct AppearWorkaround: ViewModifier {
	public typealias Action = () -> Void
	private let action: Action?
	
	@State private var isFirstTime = true
//	@State private var lastFired: Date = Date.reference0
	@Environment(\.presentationMode) private var presentation
	
	public init(
		perform action: Action? = .none
	) {
		self.action = action
	}
	
	public func body(content: Content) -> some View {
		content
			.onAppear  {
				if presentation.wrappedValue.isPresented || isFirstTime {
					isFirstTime = false
					self.action?()
				}

				/*
				let now: Date = .now
				let timePassed = lastFired.distance(to: now)
				print("=== timePassed: \(timePassed)")
				let canFire = lastFired.isReference0
					|| presentation.wrappedValue.isPresented && timePassed > 100
				if canFire {
					lastFired = now
					self.action?()
				}
				*/
			}
			/*
			.onChange(of: presentation.wrappedValue.isPresented) { isPresented in
				
			}
			*/
	}
}
*/
