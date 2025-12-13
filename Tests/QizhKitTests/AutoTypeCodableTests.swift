#if swift(>=6.2) && canImport(Testing)
import Testing
import Foundation
@testable import QizhKit

private struct MixedPayload: Codable, Equatable {
	@AutoTypeCodable var int: Int
	@AutoTypeCodable var double: Double
	@AutoTypeCodable var decimal: Decimal
	@AutoTypeCodable var bool: Bool
	@AutoTypeCodable var date: Date?
	
	init(
		int: Int,
		double: Double,
		decimal: Decimal,
		bool: Bool,
		date: Date?
	) {
		self.int = int
		self.double = double
		self.decimal = decimal
		self.bool = bool
		self.date = date
	}
}

private struct LossyPayload: Codable, Equatable {
	@LossyAutoTypeCodable var int: Int
	@LossyAutoTypeCodable var optInt: Int?
}

@Suite("AutoTypeCodable tests")
struct AutoTypeCodableTests {
	private let dateFormatter: DateFormatter = {
		let formatter = DateFormatter()
		formatter.dateFormat = "dd.MM.yyyy HH:mm"
		formatter.locale = Locale(identifier: "en_US_POSIX")
		return formatter
	}()
	
	private func date(_ str: String) -> Date {
		guard let d = dateFormatter.date(from: str) else {
			fatalError("Invalid date string for test: \(str)")
		}
		return d
	}
	
	@Test("Decoding mixed representations")
	func testDecodingMixedRepresentations() throws {
		let json = """
			{
				"int": "42",
				"double": 3.1415,
				"decimal": "2.71828",
				"bool": 1,
				"date": "13.12.2025 14:30"
			}
			"""
		let data = Data(json.utf8)
		let decoded = try JSONDecoder().decode(MixedPayload.self, from: data)
		
		#expect(decoded.int == 42)
		#expect(abs(decoded.double - 3.1415) <= 0.00001)
		#expect(decoded.decimal == Decimal(string: "2.71828"))
		#expect(decoded.bool == true)
		
		let d = try #require(decoded.date, "Date decoding failed unexpectedly")
		/// Compare by reformatting to string to avoid TZ issues
		let decodedDateStr = dateFormatter.string(from: d)
		#expect(decodedDateStr == "13.12.2025 14:30")
	}
	
	@Test("Round-trip encoding and decoding")
	func testRoundTripEncodesAndDecodes() throws {
		let original = MixedPayload(
			int: 7,
			double: 1.618,
			decimal: Decimal(string: "0.57721")!,
			bool: false,
			date: date("01.01.2024 00:00")
		)
		let encoder = JSONEncoder()
		let data = try encoder.encode(original)
		
		let decoder = JSONDecoder()
		let decoded = try decoder.decode(MixedPayload.self, from: data)
		#expect(decoded == original)
	}
	
	@Test("Null optional date yields nil during decoding")
	func testDecodingNullOptionalDateYieldsNil() throws {
		let json = """
			{
				"int": 0,
				"double": 0,
				"decimal": 0,
				"bool": 0,
				"date": null
			}
			"""
		let decoded = try JSONDecoder().decode(MixedPayload.self, from: Data(json.utf8))
		#expect(decoded.date == nil)
	}
	
	@Suite("LossyAutoTypeCodable")
	struct LossyAutoTypeCodableTests {
		@Test("Missing keys produce default and nil")
		func testMissingKeysProduceDefaultAndNil() throws {
			let json = "{}"
			let decoded = try JSONDecoder().decode(LossyPayload.self, from: Data(json.utf8))
			#expect(decoded.int == 0)
			#expect(decoded.optInt == nil)
		}
		
		@Test("Invalid types produce default and nil")
		func testInvalidTypesProduceDefaultAndNil() throws {
			let json = """
				{
					"int": "not a number",
					"optInt": "also no number"
				}
				"""
			let decoded = try JSONDecoder().decode(LossyPayload.self, from: Data(json.utf8))
			#expect(decoded.int == 0)
			#expect(decoded.optInt == nil)
		}
		
		@Test("Valid values decode correctly")
		func testValidValuesDecodeCorrectly() throws {
			let json = """
				{
					"int": 123,
					"optInt": 456
				}
				"""
			let decoded = try JSONDecoder().decode(LossyPayload.self, from: Data(json.utf8))
			#expect(decoded.int == 123)
			#expect(decoded.optInt == 456)
		}
	}
}

#endif

