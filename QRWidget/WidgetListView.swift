//
//  ContentView.swift
//  QRWidget
//
//  Created by Haruta Yamada on 2020/10/08.
//

import SwiftUI
import CoreData

enum Destination: Hashable {
    case editor(widget: WidgetModel)
    case picker
}

extension Destination: Identifiable {
    var id: Self {
        return self
    }
}

struct WidgetListView: View {
    @Environment(\.managedObjectContext) private var viewContext

    @FetchRequest(
        sortDescriptors: [],
        animation: .default)
    private var widgets: FetchedResults<WidgetModel>
    @State var sheet: Destination? = nil
    @State var originCode: String? = nil
    @State var isPreview: Bool = false

    var body: some View {
        List {
            Section {
                ForEach(widgets) { widget in
                    Button(action: {
                        sheet = .editor(widget: widget)
                    }, label: {
                        Text(widget.title!)
                            .foregroundColor(.primary)
                    })
                }
                .onDelete(perform: deleteItems)
            }
            Button (action: {
                sheet = .picker
            }, label: {
                Text("Add QRCode")
                    .multilineTextAlignment(.center)
                    .frame(maxWidth: .infinity)
            })
        }
        .navigationBarItems(trailing: EditButton())
        .listStyle(InsetGroupedListStyle())
        .navigationTitle("QRWidget")
        .sheet(item: $sheet) { destination in
            switch destination {
            case .editor(let widget):
                NavigationView {
                    WidgetEditor(widget: widget, destination: $sheet)
                        .environment(\.managedObjectContext, viewContext)
                }
            case .picker:
                if isPreview {
                    Text("Hello")
                } else {
                    QRCodePickerView(destination: $sheet)
                        .ignoresSafeArea(.all, edges: .bottom)
                }
            }
        }
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            offsets.map { widgets[$0] }.forEach(viewContext.delete)

            do {
                try viewContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
        }
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    formatter.timeStyle = .medium
    return formatter
}()

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            WidgetListView(isPreview: true)
                .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        }
    }
}
