//
//  TextView.swift
//  QRWidget
//
//  Created by Haruta Yamada on 2020/10/11.
//

import SwiftUI

struct TextView: View {
    var body: some View {
        HStack(alignment: .top) {
            Image("face")
                .resizable()
                .scaledToFill()
                .frame(width: 50, height: 50, alignment: .center)
                .clipShape(Circle())
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    Text("Hello, World!")
                        .bold()
                        .foregroundColor(.black)
                    Text("@hello_world")
                        .foregroundColor(.gray)
                }
                Text("Twitterを始めました\nIniad生です")
            }
        }
    }
}

struct TextView_Previews: PreviewProvider {
    static var previews: some View {
        TextView()
    }
}
