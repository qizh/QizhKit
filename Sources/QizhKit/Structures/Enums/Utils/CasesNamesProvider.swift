//
//  EnumCasesNamesProvider.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 13.08.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import Foundation

public func casesNames(of type: Any.Type) -> [String] {
	var metadata = EnumMetadata(for: type)
	return metadata.cases()
}

/*
public func casesKeys <Keys> (of type: Keys.Type) -> [String: String]
	where
	Keys: CodingKey,
	Keys: CaseIterable,
	Keys: RawRepresentable,
	Keys.RawValue == String
{
	casesNames(of: type)
		.map { name in
			Keys(stringValue: <#T##String#>)
		}
}

public func caseValue(for )
*/

struct EnumMetadata {
	let pointer: UnsafeMutablePointer<EnumMetadataLayout>
	
	init(for type: Any.Type) {
		self.pointer = unsafeBitCast(type, to: UnsafeMutablePointer<EnumMetadataLayout>.self)
	}
	
	mutating func cases() -> [String] {
		guard pointer.pointee.typeDescriptor.pointee.fieldDescriptor.offset.isNotZero
		else { return .empty }
		
		let fieldDescriptor = pointer.pointee.typeDescriptor.pointee.fieldDescriptor.advanced()
		let numberOfCases = pointer.pointee.typeDescriptor.pointee.numEmptyCases
		let rangeOfCases = 0 ..< Int(numberOfCases)
		return rangeOfCases.map { i in
			fieldDescriptor.pointee.fields.element(at: i).pointee.fieldName()
		}
	}
	
	struct EnumMetadataLayout {
		let kind: UInt8
		let typeDescriptor: UnsafeMutablePointer<EnumTypeDescriptor>
		
		struct EnumTypeDescriptor {
			var flags: Int32
			var parent: RelativePointer<Int32, UnsafeRawPointer>
			var mangledName: RelativePointer<Int32, CChar>
			var accessFunctionPointer: RelativePointer<Int32, UnsafeRawPointer>
			var fieldDescriptor: RelativePointer<Int32, FieldDescriptor>
			var numPayloadCasesAndPayloadSizeOffset: UInt32
			var numEmptyCases: UInt32
			var offsetToTheFieldOffsetVector: RelativeVectorPointer<Int32, Int32>
			var genericContextHeader: TargetTypeGenericContextDescriptorHeader
			
			struct TargetTypeGenericContextDescriptorHeader {
				var instantiationCache: Int32
				var defaultInstantiationPattern: Int32
				var base: TargetGenericContextDescriptorHeader
				
				struct TargetGenericContextDescriptorHeader {
					var numberOfParams: UInt16
					var numberOfRequirements: UInt16
					var numberOfKeyArguments: UInt16
					var numberOfExtraArguments: UInt16
				}
			}
			
			struct FieldDescriptor {
				var mangledTypeNameOffset: Int32
				var superClassOffset: Int32
				var _kind: UInt16
				var fieldRecordSize: Int16
				var numFields: Int32
				var fields: Vector<FieldRecord>
				
				struct FieldRecord {
					var fieldRecordFlags: Int32
					var _mangledTypeName: RelativePointer<Int32, Int8>
					var _fieldName: RelativePointer<Int32, UInt8>
					
					mutating func fieldName() -> String {
						String(cString: _fieldName.advanced())
					}
				}
			}
		}
	}
}
