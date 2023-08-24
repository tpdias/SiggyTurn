//
//  ColorExtension.swift
//  SiggyTurn
//
//  Created by Pedro Mezacasa Muller on 23/08/23.
//

import Foundation
import SwiftUI

extension Color {
 
    static func randomStrong() -> Color {
        
//        let strongRow: Int = Int.random(in: 0...2)
//
//        return Color(red: Double.random(in: strongRow == 0 ? 0...1 : 0...0.5),
//                     green: Double.random(in: strongRow == 1 ? 0...1 : 0...0.5),
//                     blue: Double.random(in: strongRow == 2 ? 0...1 : 0...0.5))
        
        return Color(red: Double.random(in: 0...1),
                     green: Double.random(in: 0...1),
                     blue: Double.random(in: 0...1))
    }
    
}
