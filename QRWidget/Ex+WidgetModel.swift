//
//  Ex+WidgetModel.swift
//  QRWidget
//
//  Created by Haruta Yamada on 2020/10/08.
//

import Foundation

extension WidgetModel {
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        id = UUID()
        title = "QRCode #\(Int.random(in: 0..<9999))"
    }
}
