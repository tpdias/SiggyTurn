//
//  ContentView.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import SwiftUI
import CoreLocation

struct ContentView: View {
    
    @StateObject var service: CompassHeading
    
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
            }
            .padding()
            
            if service.bugged {
                Rectangle()
                    .foregroundColor(.green)
                    .ignoresSafeArea()
            }
        }
    }
}
