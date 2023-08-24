//
//  ExtensionUserDefault.swift
//  SiggyTurn
//
//  Created by Pedro Mezacasa Muller on 23/08/23.
//

import Foundation

extension UserDefaults {
    var numberOfSpins: Int {
        get {
            return (UserDefaults.standard.value(forKey: "numberOfSpins") as? Int) ?? 0
        }
        
        set {
            UserDefaults.standard.set(newValue, forKey: "numberOfSpins")
        }
    }
}
