//
//  Stack.swift
//  configen
//
//  Created by Suyash Srijan on 13/01/2020.
//  Copyright © 2020 The App Business. All rights reserved.
//

import Foundation

/// A collection of elements which which can be accessed and modified in LIFO (last in, first out) order
final class Stack<T> {
	private var elements: [T] = []

	/// Is the stack empty?
	var isEmpty: Bool {
		return elements.isEmpty
	}

	/// Push an element onto the stack
	func push(_ element: T) {
		elements.append(element)
	}

	/// Pop an element off the stack
	func pop() {
		_ = elements.popLast()
	}

	/// Return the item on the stack
	func peek() -> T? {
		return elements.last
	}
}
