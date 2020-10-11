//
//  Ex+View.swift
//  QRWidget
//
//  Created by Haruta Yamada on 2020/10/08.
//

import SwiftUI

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
