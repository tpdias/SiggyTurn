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
    @State var top3: [SiggyUserModel] = []
    private let timer = Timer.publish(every: 5, on: .main, in: .common).autoconnect()
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
            .onAppear(){
                cloud.fetchUser {
                }
                Task {
                    await cloud.fetchAllUsers()
                    top3 = cloud.users
                }
            }
            .onReceive(timer) { _ in
                if(cloud.localUser == nil){
                    cloud.fetchUser {
                    }
                }
                cloud.update(newTurns: service.numberOfSpins)
                cloud.fetchAllUsers()
                top3 = cloud.users
            }
    }
    var screen: some View {
        VStack{
            ZStack {
                VStack {
                    Text(String(service.numberOfSpins))
                        .foregroundColor(currentColor)
                        .font(.system(size: service.didChangeSpin ? 100 : 60))
                        .shadow(color: currentColor, radius: 8)
                        .shadow(color: currentColor, radius: 8)
                    HStack{
                        Text("L \(service.leftStack)")
                        Text("R \(service.rightStack)")
                    }
                    Text("Best Turners")
                        .font(.headline)
                        .foregroundColor(currentColor)
                        .shadow(color: currentColor, radius: 3)
                        .padding(.top, 20)
                        .padding(.bottom, -8)
                    List(top3.prefix(3), id: \.username) { user in
                        HStack {
                            Text(user.username)
                                .font(.headline)
                                .foregroundColor(currentColor)
                                .shadow(color: currentColor, radius: 3)
                            Spacer()
                            Text("Turns: \(user.turns)")
                                .foregroundColor(currentColor)
                                .shadow(color: currentColor, radius: 3)
                        }
                        .listRowBackground(
                            Color.clear
                        )
                    }
                    .listStyle(.plain)
                    .frame(maxHeight: 200)
                    .background(Color.clear)
                    //.scrollContentBackground(.hidden)
                    .ignoresSafeArea(.all)
                }
                .padding()
                .animation(.easeInOut, value: service.bugged)
                .animation(.easeInOut, value: service.didChangeSpin)
                .rotationEffect(Angle(degrees: -1 * (service.trueHeading - service.offSet)))
                
                Circle()
                    .foregroundColor(currentColor)
                    .shadow(color: currentColor, radius: 8)
                    .frame(width: 10, height: 10)
                    .position(x: UIScreen.main.bounds.midX , y: UIScreen.main.bounds.minY - 40 + UIScreen.main.bounds.maxY * (abs(180 - max(service.rightStack, service.leftStack))/185.0))
                    .rotationEffect(Angle(degrees: -1 * (service.trueHeading - service.offSet)))
            }
//            Rectangle()
//                .frame(width: 200, height: 8)
//            Text("X: \(UIScreen.main.bounds.midX)")
//            Text("Y: \(UIScreen.main.bounds.midY), \(UIScreen.main.bounds.maxY)")
            }
    }
    
}
