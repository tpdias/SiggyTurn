//
//  SiggyTurnApp.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import SwiftUI

@main
struct SiggyTurnApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
