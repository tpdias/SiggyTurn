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
    private let generatorRestoDez: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let standardGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    @EnvironmentObject var service: CompassHeading
    @State var currentColor: Color = .white
    
    var body: some View {
        screen
            .onReceive(service.$numberOfSpins) { booleano in
                if service.numberOfSpins % 10 == 0 {
                    generatorRestoDez.impactOccurred()
                } else {
                    standardGenerator.impactOccurred()
                }
                
                currentColor = Color.randomStrong()
            }
    }
    
    var screen: some View {
        screen
            .onReceive(service.$numberOfSpins) { booleano in
                if service.numberOfSpins % 10 == 0 {
                    generatorRestoDez.impactOccurred()
                } else {
                    standardGenerator.impactOccurred()
                }
                
                currentColor = Color.randomStrong()
            }
    }
    var screen: some View {
        VStack {
            Text(String(service.numberOfSpins))
                .foregroundColor(currentColor)
                .font(.system(size: service.didChangeSpin ? 100 : 60))
                .shadow(color: currentColor, radius: 8)
                .shadow(color: currentColor, radius: 8)
            List(cloud.users.prefix(3), id: \.username) { user in
                HStack {
                    Text(user.username)
                        .font(.headline)
                        .foregroundColor(curColor)
                        .shadow(color: .white, radius: 3)
                    Spacer()
                    Text("Turns: \(user.turns)")
                        .foregroundColor(curColor)
                        .shadow(color: .white, radius: 3)
                }
                .listRowSeparator(.visible)
                .listRowBackground(
                    Color.clear
                )
            }
            // .frame(maxHeight: 200)
            
            .scrollContentBackground(.hidden)
            .ignoresSafeArea(.all)
        }
        .padding()
        .animation(.easeInOut, value: service.bugged)
        .animation(.easeInOut, value: service.didChangeSpin)
        .rotationEffect(Angle(degrees: -1 * (service.trueHeading - service.offSet)))
        .onAppear(){
            Task {
                await cloud.fetchAllUsers()
            }
            
            
            //ordenar os usuários por turns
            //cloud.users

    }
}
        
       
