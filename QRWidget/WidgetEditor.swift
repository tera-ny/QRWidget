//
//  WidgetEditor.swift
//  QRWidget
//
//  Created by Haruta Yamada on 2020/10/08.
//

import SwiftUI
import Combine

struct WidgetEditor: View {
    let widget: WidgetModel
    @Environment(\.managedObjectContext) var viewContext
    @State var title: String
    @State var memo: String
    @State var code: String

    @Binding var destination: Destination?
    var limit: Int {
        500-code.count
    }
    init(widget: WidgetModel, destination: Binding<Destination?>) {
        self.widget = widget
        self._title = .init(initialValue: (widget.title ?? ""))
        self._memo = .init(initialValue: (widget.memo ?? ""))
        self._destination = destination
        self._code = .init(initialValue: widget.code!)
    }
    var body: some View {
        ScrollView {
            VStack(alignment: .leading) {
                Text("title")
                    .bold()
                TextField("QRCode title", text: $title)
                    .font(.system(size: 18, weight: .medium, design: .rounded))
                    .padding(.horizontal)
                Text("memo")
                    .bold()
                    .padding(.top, 10)
                TextEditor(text: $memo)
                    .padding(.horizontal)
                HStack {
                    Text("origin code").bold()
                    Spacer()
                    Text("\(limit)")
                        .font(.system(size: 15, weight: .thin, design: .monospaced))
                }
                    .padding(.top, 10)
                TextField("orign code", text: $code)
                    .font(.system(size: 25, weight: .heavy, design: .monospaced))
                    .padding()
                Text("generated image")
                    .bold()
                    .padding(.vertical, 10)
                HStack {
                    Spacer(minLength: 50)
                    QRCodeView(code: code)
                        .padding(.top, 30)
                    Spacer(minLength: 50)
                }
            }
            .padding()
        }
        .navigationTitle("Edit QRCode")
        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarItems(trailing: Button("保存", action: {
            widget.title = title
            widget.memo = memo
            widget.code = code
            do {
                try viewContext.save()
                destination = .none
            } catch {
                print(error)
            }
        }).disabled(limit < 0))
    }
}

struct WidgetEditor_Previews: PreviewProvider {
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let model = WidgetModel(context: context)
        model.memo = "initializeMemo"
        model.code = "hogehoge"
        try? context.save()
        return NavigationView {
            WidgetEditor(widget: model, destination: .constant(.editor(widget: model)))
                        .environment(\.managedObjectContext, context)
        }
    }
}
