//
//  String+closest.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.04.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

// MARK: Sort

public extension Collection where Element == String {
	func sorted<Measure: Comparable>(
		using measurementKey: IncreasingOrder.Key<Measure>,
		from sample: String
	) -> [String] {
		sorted(
			by: DistanceMeasurement<String>.makeComparator(
				for: stringCalculators[keyPath: measurementKey],
				from: sample
			)
		)
	}
	
	@inlinable func sorted(
		using measurement: DistanceMeasurement<Element>.CompareOrder
	) -> [Element] {
		sorted(by: measurement)
	}
}

public extension Collection where Self: EmptyTestable, Element == String {
	@inlinable func closest<Measure: Comparable>(
		to sample: String,
		using measurementKey: IncreasingOrder.Key<Measure>
	) -> String? {
		nonEmpty.flatMap { collection in
			collection
				.sorted(using: measurementKey, from: sample)
				.first
		}
	}
}

// MARK: Measurement Provider

public extension Collection where Element == String {
	typealias IncreasingOrder = DistanceMeasurement<String>.IncreasingOrder
	typealias CalculateDistance<Measure: Comparable> =
		DistanceMeasurement<String>.CalculateDistance<Measure>
}

public struct DistanceMeasurement<Element> {
	public typealias CalculateDistance<Value: Comparable>
		= (Element, Element) -> Value
//		= (Element, Element) throws -> Value
	public typealias CompareOrder
		= (Element, Element) -> Bool
//		= (Element, Element) throws -> Bool

	public static func makeComparator<Value: Comparable>(
		for distance: @escaping CalculateDistance<Value>,
		from sample: Element
	) -> CompareOrder {
		{ distance(sample, $0) > distance(sample, $1) }
	}
	
	public struct IncreasingOrder: Sendable {
		public typealias Key<Measure: Comparable> = KeyPath<IncreasingOrder, CalculateDistance<Measure>>
		fileprivate init() { }
	}
}

fileprivate let stringCalculators = DistanceMeasurement<String>.IncreasingOrder()

public extension DistanceMeasurement.IncreasingOrder where Element == String {
	
	// MARK: Levenshtein 1
	
//	@inlinable static func levenshtein1(_ lhs: String, _ rhs: String) -> Double {
//		Self.levenshtein1(
//			lhs, rhs,
//			caseInsensitive: true,
//			trimming: false
//		)
//	}
	
	var levenshtein1Distance: DistanceMeasurement.CalculateDistance<Double> {
		levenshtein1
	}
	
	func levenshtein1(_ lhs: String, _ rhs: String) -> Double {
//		_ lhs: String,
//		_ rhs: String,
//		caseInsensitive: Bool = true,
//		trimming: Bool = true
//	)
//		-> Double
//	{
//		var lhs = lhs
//		var rhs = rhs
//
//		if caseInsensitive {
//			stringL = stringL.lowercased()
//			stringR = stringR.lowercased()
//		}
//
//		if trimming {
//			stringL = stringL.trimmingCharacters(in: .whitespacesAndNewlines)
//			stringR = stringR.trimmingCharacters(in: .whitespacesAndNewlines)
//		}
		
		/// `[0, 0, 0, ..., 0]`
		let empty: [Int] =
			Array(
				repeating: 0,
				count: rhs.count
			)
		
		/// `[0, 1, 2, ..., count]`
		var prvious: [Int] = Array( 0 ... rhs.count )
		
		let charsL = lhs.enumerated().map(EnumeratedCharacter.init)
		let charsR = rhs.enumerated().map(EnumeratedCharacter.init)

		charsL.forEach { left in
			var current: [Int] = [ left.pos + 1 ] + empty
			
			charsR.forEach { right in
				
				current[ right.pos + 1 ] =
					( left.chr == right.chr )
					? prvious[ right.pos ]
					: Swift
						.min(
							prvious[ right.pos     ],
							prvious[ right.pos + 1 ],
							current[ right.pos     ]
						) + 1
			}
			
			prvious = current
		}
		
		let max: Int =
			[lhs, rhs]
				.map(\.count).max()
				.forceUnwrap(because: "There should definitely be max element out of two")
		
		let percent = prvious.last
			.map { same in
				1 - (same.dbl / max.dbl)
			}
		
		return percent ?? 0
	}
	
	// MARK: Levenshtein 2
	
	var levenshtein2Distance: DistanceMeasurement.CalculateDistance<Int> {
		levenshtein2
	}
	
	func levenshtein2(aStr: String, bStr: String) -> Int {
		/// create character arrays with `Int` index
		let a = Array(aStr)
		let b = Array(bStr)

		/// # Distance
		/// Initialize matrix of size `|a|+1 * |b|+1` with zero
		var d = [[Int]].init()
		
		for _ in (0 ... a.count) {
			d += [
				[Int].init(
					repeating: 0,
					count: b.count + 1
				)
			]
		}

		/// `a` prefixes can be transformed into empty string by deleting every char
		for x in (1 ... a.count) {
			d[x][0] = x
		}

		/// `b` prefixes can be created from empty string by inserting every char
		for y in (1 ... b.count) {
			d[0][y] = y
		}

		for x in (1 ... a.count) {
			for y in (1 ... b.count) {
				if a[x-1] == b[y-1] {
					d[x][y] = d[x-1][y-1]  // noop
				} else {
					d[x][y] = Swift.min(
						d [x-1] [y  ] + 1,  // deletion
						d [x  ] [y-1] + 1,  // insertion
						d [x-1] [y-1] + 1  // substitution
					)
				}
			}
		}

		let result = d[a.count][b.count]
		return -result
	}
	
	// MARK: Damerau Levenshtein
	
	var damerauLevenshteinDistance: DistanceMeasurement.CalculateDistance<Int> {
		damerauLevenshtein
	}
	
	func damerauLevenshtein(_ lhs: String, _ rhs: String) -> Int {
		let left = Array(lhs)
		let rght = Array(rhs)
		
        let leftCount = left.count
        let rghtCount = rght.count

        if left == rght {
            return 0
        }
        if leftCount == 0 {
            return rghtCount
        }
        if rghtCount == 0 {
            return leftCount
        }

        var da: [Character: Int] = [:]

        var d = Array(repeating: Array(repeating: 0, count: rghtCount + 2), count: leftCount + 2)

        let maxdist = leftCount + rghtCount
        d[0][0] = maxdist
        for i in 1...leftCount + 1 {
            d[i][0] = maxdist
            d[i][1] = i - 1
        }
        for j in 1...rghtCount + 1 {
            d[0][j] = maxdist
            d[1][j] = j - 1
        }

        for i in 2...leftCount + 1 {
            var db = 1

            for j in 2...rghtCount + 1 {
                let k = da[rght[j - 2]] ?? 1
                let l = db

                var cost = 1
                if left[i - 2] == rght[j - 2] {
                    cost = 0
                    db = j
                }

                let substition = d[i - 1][j - 1] + cost
                let injection = d[i][j - 1] + 1
                let deletion = d[i - 1][j] + 1
                let leftIdx = i - k - 1
                let rghtIdx = j - l - 1
                let transposition = d[k - 1][l - 1] + leftIdx + 1 + rghtIdx

                d[i][j] = Swift.min(
                    substition,
                    injection,
                    deletion,
                    transposition
                )
            }

            da[left[i - 2]] = i
        }

        let result = d[leftCount + 1][rghtCount + 1]
		return -result
    }
	
	// MARK: Jaro Winkler
	
	var jaroWinklerDistance: DistanceMeasurement.CalculateDistance<Double> {
		jaroWinkler
	}
	
    func jaroWinkler(_ lhs: String, _ rhs: String) -> Double {
        var stringOne = lhs
        var stringTwo = rhs
        if stringOne.count > stringTwo.count {
            stringTwo = lhs
            stringOne = rhs
        }

        let stringOneCount = stringOne.count
        let stringTwoCount = stringTwo.count

        if stringOneCount == 0 && stringTwoCount == 0 {
            return 1.0
        }

        let matchingDistance = stringTwoCount / 2
        var matchingCharactersCount: Double = 0
        var transpositionsCount: Double = 0
        var previousPosition = -1

        // Count matching characters and transpositions.
        for (i, stringOneChar) in stringOne.enumerated() {
            for (j, stringTwoChar) in stringTwo.enumerated() {
				if Swift.max(0, i - matchingDistance)..<Swift.min(stringTwoCount, i + matchingDistance) ~= j {
                    if stringOneChar == stringTwoChar {
                        matchingCharactersCount += 1
                        if previousPosition != -1 && j < previousPosition {
                            transpositionsCount += 1
                        }
                        previousPosition = j
                        break
                    }
                }
            }
        }

        if matchingCharactersCount == 0.0 {
            return 0.0
        }

        // Count common prefix (up to a maximum of 4 characters)
        let commonPrefixCount = Swift.min(Swift.max(Double(lhs.commonPrefix(with: rhs).count), 0), 4)

        let jaroSimilarity = (matchingCharactersCount / Double(stringOneCount) + matchingCharactersCount / Double(stringTwoCount) + (matchingCharactersCount - transpositionsCount) / matchingCharactersCount) / 3

        // Default is 0.1, should never exceed 0.25 (otherwise similarity score could exceed 1.0)
        let commonPrefixScalingFactor = 0.1

        return jaroSimilarity + commonPrefixCount * commonPrefixScalingFactor * (1 - jaroSimilarity)
    }
}

// MARK: Required Extensions

fileprivate extension Int {
	var dbl: Double { Double(self) }
}

fileprivate struct EnumeratedCharacter {
	let pos: Int
	let chr: Character
	
	init(_ element: EnumeratedSequence<String>.Element) {
		pos = element.offset
		chr = element.element
	}
}
