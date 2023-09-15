//
//  ContentView.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    @State private var isLoading = false
    @EnvironmentObject var cloud: CKCrudService
    @EnvironmentObject var cloudUser: CloudKitUserViewModel
    private let generatorRestoDez: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
    private let standardGenerator: UIImpactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    @EnvironmentObject var service: CompassHeading
    @State var currentColor: Color = .white
    @State var top3: [SiggyUserModel] = []
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
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
                isLoading = true
            }
            .onChange(of: cloudUser.userID, perform: { newValue in
                cloud.localUserICloudID = cloudUser.userID
                CKUtilityService.discoverUserName()
                   .receive(on: DispatchQueue.main)
                   .sink { _ in

                   } receiveValue: { name in
                       cloud.localUserName = name
                       isLoading = false
                }
                cloud.fetchUser()
                Task {
                    await cloud.fetchAllUsers()
                    top3 = cloud.users
                }
                isLoading = false
                
            })
            .onReceive(timer) { _ in
                if(!isLoading){
                    cloud.update(newTurns: service.numberOfSpins)
                    cloud.fetchAllUsers()
                    top3 = cloud.users
                }
            }
    }
    var screen: some View {
        VStack {
            Text(String(service.numberOfSpins))
                .foregroundColor(currentColor)
                .font(.system(size: service.didChangeSpin ? 100 : 60))
                .shadow(color: currentColor, radius: 8)
                .shadow(color: currentColor, radius: 8)
            if(isLoading){
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: currentColor))
                    .scaleEffect(2)
            }
            else {
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
        }
        .padding()
        .animation(.easeInOut, value: service.bugged)
        .animation(.easeInOut, value: service.didChangeSpin)
        .rotationEffect(Angle(degrees: -1 * (service.trueHeading - service.offSet)))
        
    }
    
}
