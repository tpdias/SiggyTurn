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
    @State var curColor: Color = .cyan
    
    var body: some View {
        ZStack{
            Rectangle()
                .foregroundColor(.black)
                .ignoresSafeArea()
            VStack {
                Text(String(service.degrees))
                    .padding()
                    .background(
                        Color.red
                        
                    )
                
                    .cornerRadius(30)
                
                Text(String(service.numberOfSpins))
                    .padding()
                    .background(
                        Color.blue
                            .shadow(color: .blue, radius: 30)
                            .shadow(color: .blue, radius: 30)
                            .shadow(color: .blue, radius: 30)
                            .shadow(color: .blue, radius: 30)
                    )
                
                    .cornerRadius(30)
                
                
                Rectangle()
                    .frame(width: 200, height: 200)
                    .foregroundColor(.yellow)
                    .shadow(color: .yellow, radius: 8)
                    .shadow(color: .yellow, radius: 8)
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
            
            if service.bugged {
                Rectangle()
                    .foregroundColor(.green)
                    .ignoresSafeArea()
            }
            
        }
        .onAppear(){
            Task {
                await cloud.fetchAllUsers()
            }
            
            
            //ordenar os usuários por turns
            //cloud.users
        }
    }
}
