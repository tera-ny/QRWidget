//
//  Widget.swift
//  Widget
//
//  Created by Haruta Yamada on 2020/10/08.
//

import WidgetKit
import SwiftUI
import CoreData

struct Provider: IntentTimelineProvider {
    
    typealias Entry = SimpleEntry
    typealias Intent = WidgetIntent
    
    private func fetchWidget(id: UUID) -> WidgetModel? {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = WidgetModel.entity()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        if let results = try? context.fetch(fetchRequest) as? [WidgetModel] {
            return results.first
        } else {
            return nil
        }
    }
    
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), model: nil)
    }

    func getSnapshot(for configuration: WidgetIntent, in context: Context, completion: @escaping (SimpleEntry) -> Void) {
        guard let id = configuration.type?.identifier else {
            completion(SimpleEntry(date: Date(), model: nil))
            return
        }
        let model = fetchWidget(id: UUID(uuidString: id)!)
        completion(SimpleEntry(date: Date(), model: model))
    }
    
    func getTimeline(for configuration: WidgetIntent, in context: Context, completion: @escaping (Timeline<SimpleEntry>) -> Void) {
        guard let id = configuration.type?.identifier else {
            completion(Timeline(entries: [SimpleEntry(date: Date(), model: nil)], policy: .never))
            return
        }
        let model = fetchWidget(id: UUID(uuidString: id)!)
        let timeLine = Timeline(entries: [SimpleEntry(date: Date(), model: model)], policy: .never)
        completion(timeLine)
    }
}

struct SimpleEntry: TimelineEntry {
    var date: Date
    
    let model: WidgetModel?
}

struct WidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        if let model = entry.model {
            VStack {
                QRCodeView(code: model.code!)
                Text(model.title!)
            }
            .padding()
        } else {
            Text("failure load")
        }
    }
}

@main
struct QRWidget: Widget {
    let kind: String = "Widget"

    var body: some WidgetConfiguration {
        IntentConfiguration(kind: kind, intent: WidgetIntent.self, provider: Provider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Small QR Widget")
        .description("This is an example widget.")
        .supportedFamilies([.systemSmall, .systemLarge])
    }
}

struct Widget_Previews: PreviewProvider {
    static let type: WidgetType = {
        let type = WidgetType(identifier: "hoge", display: "piyo")
        type.code = "what your color?"
        return type
    }()
    static var previews: some View {
        let context = PersistenceController.preview.container.viewContext
        let model = WidgetModel(context: context)
        model.memo = "initializeMemo"
        model.code = "hogehoge"
        try? context.save()
        return Group {
            WidgetEntryView(entry: SimpleEntry(date: Date(), model: model))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
            WidgetEntryView(entry: SimpleEntry(date: Date(), model: nil))
                .previewContext(WidgetPreviewContext(family: .systemSmall))
        }
    }
}
