//
//  QRCodeImage.swift
//  QizhKit
//
//  Created by Serhii Shevchenko on 28.07.2020.
//  Copyright © 2020 Serhii Shevchenko. All rights reserved.
//

import SwiftUI
import CoreImage
import CoreImage.CIFilterBuiltins

public struct QRCodeImage: View {
	public let source: String
	private let context = CIContext()
	
	public init(source: String) {
		self.source = source
	}
	
	@ViewBuilder
	public var body: some View {
		if let image = Self.codeImage(from: source, using: context) {
			Image(uiImage: image)
				.interpolation(.none)
				.resizable()
		}
	}
	
	public static func codeImage(from string: String, using context: CIContext) -> UIImage? {
		guard let data = string.data(using: .ascii) else { return nil }
		
		let filter = CIFilter.qrCodeGenerator()
		filter.message = data
		
		let scale: CGFloat = UIScreen.main.scale // .three
		let transform = CGAffineTransform(scaleX: scale, y: scale)
		
		if let output = filter.outputImage?.transformed(by: transform),
		   let cgImage = context.createCGImage(output, from: output.extent.inset(scale)) {
			return UIImage(cgImage: cgImage)
		}
		
		return nil
	}
}

// MARK: Previews

#if DEBUG
struct QRCodeImage_Previews: PreviewProvider {
    static var previews: some View {
		Group {
			QRCodeImage(source: "test")
//				.previewDifferentDevices(names: true)
				.previewDisplayName("test")
			
			QRCodeImage(source: "some much longer value")
//				.previewDifferentDevices(names: true)
				.previewDisplayName("some much longer value")
		}
		.previewLayout(.fixed(width: UIScreen.main.scale * 150, height: UIScreen.main.scale * 150))
    }
}
#endif
