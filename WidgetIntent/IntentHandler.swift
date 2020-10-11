//
//  IntentHandler.swift
//  WidgetIntent
//
//  Created by Haruta Yamada on 2020/10/08.
//

import Intents
import CoreData

class IntentHandler: INExtension {
    
    override func handler(for intent: INIntent) -> Any {
        // This is the default implementation.  If you want different objects to handle different intents,
        // you can override this and return the handler you want for that particular intent.
        
        return self
    }
    
}

extension IntentHandler: WidgetIntentHandling {
    private func fetchWidgets() -> [WidgetType] {
        let context = PersistenceController.shared.container.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>()
        fetchRequest.entity = WidgetModel.entity()
        if let results = try? context.fetch(fetchRequest) as? [WidgetModel] {
            return results.compactMap {
                let type = WidgetType(identifier: $0.id?.uuidString, display: $0.title!)
                type.code = $0.code
                return type
            }
        } else {
            return [WidgetType]()
        }
    }
    func provideTypeOptionsCollection(for intent: WidgetIntent, with completion: @escaping (INObjectCollection<WidgetType>?, Error?) -> Void) {
        completion(INObjectCollection(items: fetchWidgets()), nil)
    }
    func defaultType(for intent: WidgetIntent) -> WidgetType? {
        fetchWidgets().first
    }
}
