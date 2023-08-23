//
//  SiggyModel.swift
//  SiggyTurn
//
//  Created by Thiago Parisotto on 23/08/23.
//

import Foundation
import CloudKit


struct CKSiggyModelNames{
    static let username = "username"
    static let turns = "turns"
    static let id = "id"
}
class SiggyUserModel: CloudKitProtocol{
    var username = ""
    var id = ""
    var record: CKRecord
    var turns = 0
    
    required init?(record: CKRecord) {
        guard let username = record[CKSiggyModelNames.username] as? String,
              let turns = record[CKSiggyModelNames.turns] as? Int,
              let id = record[CKSiggyModelNames.id] as? String else { return nil }
        self.id = id
        self.username = username
        self.turns = turns
        self.record = record
    }
    
    convenience init?(username: String, turns: Int, id: String){
        let record = CKRecord(recordType: "SiggyTurn")
        record[CKSiggyModelNames.id] = id
        record[CKSiggyModelNames.turns] = turns
        record[CKSiggyModelNames.username] = username
        self.init(record: record)
    }
    func update(newTurns: Int) -> SiggyUserModel? {
        let record = record
        record[CKSiggyModelNames.turns] = newTurns
        return SiggyUserModel(record: record)
    }
}
