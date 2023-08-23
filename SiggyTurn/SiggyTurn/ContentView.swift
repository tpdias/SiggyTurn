//
//  ContentView.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var cloud: CKCrudService
    @StateObject var service: CompassHeading
    
    var body: some View {
        TabView{
            GameView()
                .environmentObject(service)
                .environmentObject(cloud)
                .tabItem {
                    Label("Game", systemImage: "gamecontroller")
                }
            RankingView()
                .environmentObject(service)
                .environmentObject(cloud)
                .tabItem {
                    Label("Ranking", systemImage: "network")
                }
        }
    }
}
