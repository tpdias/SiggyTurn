//
//  SiggyTurnApp.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import SwiftUI

extension UserDefaults {
    var userID: String {
        get {
            return (UserDefaults.standard.value(forKey: "userID") as? String) ?? ""
        }
        set {
            UserDefaults.standard.setValue(newValue, forKey: "userID")
        }
    }
}

@main
struct SiggyTurnApp: App {
    @StateObject var cloud = CKCrudService{}
    var body: some Scene {
        WindowGroup {
            ContentView(service: CompassHeading())
                .environmentObject(cloud)
        }
    }
}
