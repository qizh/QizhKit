//
//  View+onReceive.swift
//  Cooktour Concierge
//
//  Created by Serhii Shevchenko on 24.03.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import Combine

public extension View {
	
	// MARK: onReceive
	
	@inlinable func onReceive<P>(
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
	
	@inlinable func onReceiveDefined<OptionalValuePublisher, Value>(
		_ publisher: OptionalValuePublisher,
		perform action: @escaping (Value) -> Void,
		flow: ExecutionFlow = .current
	) -> some View
		where
			OptionalValuePublisher: Publisher,
			OptionalValuePublisher.Output == Value?,
			OptionalValuePublisher.Failure == Never
	{
		onReceive(publisher) { optionalValue in
			optionalValue.map { value in
				flow.proceed(with: action, value)
			}
		}
	}
	
	@inlinable func onReceiveDefined<OptionalValuePublisher, Value>(
		_ publisher: OptionalValuePublisher,
		perform action: @escaping () -> Void,
		flow: ExecutionFlow = .current
	) -> some View
		where
			OptionalValuePublisher: Publisher,
			OptionalValuePublisher.Output == Value?,
			OptionalValuePublisher.Failure == Never
	{
		onReceive(publisher) { optionalValue in
			optionalValue.map { _ in
				flow.proceed(with: action)
			}
		}
	}
	
	@inlinable func onReceiveValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping (Value) -> Void
	) -> some View
		where
			StatePublisher: Publisher,
			StatePublisher.Output == BackendFetchState<Value>,
			StatePublisher.Failure == Never
	{
		onReceive(publisher) { state in
			state.value.map { value in
				action(value)
			}
		}
	}
	
	func onReceiveFirstValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping (Value.Element) -> Void,
		_ flow: ExecutionFlow = .current
	) -> some View
		where
		Value: Collection,
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
	
	func onReceiveFirstValue<StatePublisher, Value>(
		_ publisher: StatePublisher,
		perform action: @escaping () -> Void,
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
	
//	@inlinable
	func assign<NonFailingPublisher, Root, Value>(
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
	func assign<NonFailingPublisher, Root, Value>(
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
	func assignValue<StatePublisher, Value, Root>(
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
	func assignValue<StatePublisher, Value, Root>(
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
	func assignFirstValue<StatePublisher, Value, Root>(
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
	func assignFirstValue<StatePublisher, Value, Root>(
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
	
	// MARK: on (Dis) Appear
	
	@inlinable @ViewBuilder func whenAppear(
		perform action: (() -> Void)? = nil
	) -> some View {
		if #available(iOS 14.0, *) {
			modifier(AppearWorkaround(perform: action))
		} else {
			onAppear(perform: action)
		}
	}
	
	@inlinable func whenAppear(perform action: @escaping () -> Void, in ms: Int) -> some View {
		whenAppear {
			execute(in: ms, action)
		}
	}
	
	@inlinable func whenAppear(in ms: Int, _ action: @escaping () -> Void) -> some View {
		whenAppear {
			execute(in: ms, action)
		}
	}
	
	@inlinable func onDisappear(in ms: Int, _ action: @escaping () -> Void) -> some View {
		onDisappear {
			execute(in: ms, action)
		}
	}
	
	@inlinable func whenAppear <Value, Root> (
		when cond: Bool = true,
	  assign  val: @autoclosure @escaping () -> Value,
		  to  key: ReferenceWritableKeyPath<Root, Value>,
		  on root: Root,
		with anim: Animation? = .none,
			 flow: ExecutionFlow = .current
	) -> some View {
		whenAppear {
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
	
	func onDisappear <Value, Root> (
		  when cond: Bool = true,
		assign  val: @autoclosure @escaping () -> Value,
			to  key: ReferenceWritableKeyPath<Root, Value>,
		    on root: Root,
		  with anim: Animation? = .none,
		       flow: ExecutionFlow = .current
	) -> some View {
		onDisappear {
			guard cond else { return }
			var exe: () -> Void = { root[keyPath: key] = val() }
			if let ani = anim { exe = { withAnimation(ani, exe) } }
			flow.proceed(with: exe)
		}
	}
}

//@available(iOS 14.0, *)
public struct AppearWorkaround: ViewModifier {
	public typealias Action = () -> Void
	private let action: Action?
	
	@State private var isFirstTime = true
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
			}
			/*
			.onChange(of: presentation.wrappedValue.isPresented) { isPresented in
				
			}
			*/
	}
}
