//
//  SiggyTurnApp.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import SwiftUI

@main
struct SiggyTurnApp: App {
    
    @StateObject var ch = CompassHeading()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(ch)
        }
    }
}
