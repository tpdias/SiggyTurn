//
//  SiggyTurnApp.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import SwiftUI
import Combine

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
    @State private var isLoading = false
    var cancellables = Set<AnyCancellable>()


    @StateObject var cloud = CKCrudService{}
    @StateObject var cloudUser = CloudKitUserViewModel()
    
    @StateObject var ch = CompassHeading()
    
    var body: some Scene {
        WindowGroup {
            ZStack{
                if(isLoading){
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                        .scaleEffect(2)
                }
                else {
                    ContentView()
                        .environmentObject(ch)
                        .environmentObject(cloud)
                }
            }
            .onAppear{
                isLoading = true
                CKUtilityService.requestApplicationPermission()
                CKUtilityService.getiCloudStatus()
                CKUtilityService.discoverUserIdentity()
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        
                    } receiveValue: { id in
                        
                        cloud.localUserICloudID = id
                    }
        
                
                CKUtilityService.discoverUserName()
                    .receive(on: DispatchQueue.main)
                    .sink { _ in
                        
                    } receiveValue: { name in
                        cloud.localUserName = name
                        cloud.fetchUser() {}
                        isLoading = false
                    }
            }
        }
        
       
    }
}
