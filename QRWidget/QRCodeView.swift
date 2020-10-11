//
//  QRCodeView.swift
//  QRWidget
//
//  Created by Haruta Yamada on 2020/10/08.
//

import SwiftUI

public struct QRCodeView: View {
    var image: UIImage = UIImage()
    static let ciContext = CIContext()
    init(code: String) {
        let cgImage = generateQRImage(code: code)
        image = cgImage != nil ? UIImage(cgImage: cgImage!) : UIImage()
    }
    public var body: some View {
        Image(uiImage: image)
            .resizable()
            .scaledToFit()
    }
    public func generateQRImage(code: String) -> CGImage? {
        guard let data = code.data(using: .utf8) else {
            return nil
        }
        let qr = CIFilter(name: "CIQRCodeGenerator", parameters: ["inputMessage": data, "inputCorrectionLevel": "L"])!
        let sizeTransform = CGAffineTransform(scaleX: 10, y: 10)
        guard let ciImage = qr.outputImage?.transformed(by: sizeTransform) else {
            return nil
        }
        let cgImage = QRCodeView.ciContext.createCGImage(ciImage, from: ciImage.extent)
        return cgImage
    }
}

struct QRCodeView_Previews: PreviewProvider {
    static var previews: some View {
        QRCodeView(code: "color")
    }
}
