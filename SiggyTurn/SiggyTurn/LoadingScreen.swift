//
//  LoadingScreen.swift
//  Spinity
//
//  Created by Thiago Parisotto on 06/09/23.
//

import SwiftUI

struct LoadingScreen: View {
    var body: some View {
        ZStack {
            if(isLoading){
                
            }
            else {
                ContentView()
            }
        }
        .onAppear{
            startNetworkCall()
        }
    }
        
    
    
    
}
