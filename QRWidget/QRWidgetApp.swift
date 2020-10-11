//
//  QRWidgetApp.swift
//  QRWidget
//
//  Created by Haruta Yamada on 2020/10/08.
//

import SwiftUI
import CoreData
import WidgetKit
import Combine

class AppObserver {
    private var cancellables: Set<AnyCancellable> = []
    init(context: NSManagedObjectContext) {
        NotificationCenter.Publisher(center: .default, name: .NSManagedObjectContextObjectsDidChange, object: context)
            .sink { _ in
                WidgetCenter.shared.reloadAllTimelines()
            }
            .store(in: &cancellables)
    }
}


@main
struct QRWidgetApp: App {
    let persistenceController = PersistenceController.preview
    let observer = AppObserver(context: PersistenceController.preview.container.viewContext)

    var body: some Scene {
        WindowGroup {
            NavigationView {
                WidgetListView()
                    .environment(\.managedObjectContext, persistenceController.container.viewContext)
            }
        }
    }
}
