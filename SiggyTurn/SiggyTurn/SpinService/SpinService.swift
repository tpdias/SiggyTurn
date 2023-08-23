//
//  SpinService.swift
//  SiggyTurn
//
//  Created by Pedro Mezacasa Muller on 23/08/23.
//

import Foundation
import CoreLocation
import Combine

class CompassHeading: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var bugged: Bool = false
    @Published var numberOfSpins: Int = 0
    
    var objectWillChange = PassthroughSubject<Void, Never>()
    var lastDirection: DirectionGoing = .right
    var degrees: Double = .zero {
        didSet {
            objectWillChange.send()
        }
    }
    
    var leftStack: Double = 0 {
        didSet {
            if leftStack >= 360 {
                leftStack = 0
                rightStack = 0
                numberOfSpins += 1
            }
            
            if leftStack >= 1 {
                rightStack = max(rightStack - leftStack, 0)
            }
        }
    }
    
    var rightStack: Double = 0 {
        didSet {
            if rightStack >= 360 {
                numberOfSpins += 1
                rightStack = 0
                leftStack = 0
            }
            
            if rightStack >= 1 {
                leftStack = max(leftStack - rightStack, 0)
            }
        }
    }
    
    private let locationManager: CLLocationManager
    
    override init() {
        self.locationManager = CLLocationManager()
        super.init()
        
        self.locationManager.delegate = self
        self.setup()
    }
    
    private func setup() {
        if CLLocationManager.headingAvailable() {
            self.locationManager.startUpdatingHeading()
        }
    }
    
    var maior: Double = 0
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        
        bugged = false
        
        if degrees == 0 {
            self.degrees = newHeading.trueHeading
            return
        }
        
        // TODO: fazer aqui a lógica de saber quantos giros o cara deu
//        if abs(newHeading.trueHeading - self.degrees) < 200 {
//            maior = max(maior, abs(newHeading.trueHeading - self.degrees))
//            print(maior)
//        } //else {
//
//            if newHeading.trueHeading - self.degrees > 200 {
//                self.degrees = 360 - newHeading.trueHeading
//            } else {
//                if newHeading.trueHeading - self.degrees < -200 {
//                    self.degrees = newHeading.trueHeading + 360
//                }
//            }
        //}
        
        if abs(newHeading.trueHeading - degrees) > 200 {
            self.degrees = newHeading.trueHeading
            bugged = true
            return
        }
        
        // base case
        if newHeading.trueHeading > self.degrees {
            rightStack += newHeading.trueHeading - self.degrees
            print(rightStack)
        } else {
            leftStack += abs(newHeading.trueHeading - self.degrees)
            print(leftStack)
        }
        
        self.degrees = newHeading.trueHeading
    }
}

enum DirectionGoing {
    case right, left
}
