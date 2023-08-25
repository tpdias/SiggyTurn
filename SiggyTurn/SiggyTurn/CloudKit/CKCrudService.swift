import SwiftUI
import CloudKit
import Combine
import CoreGraphics

class CKCrudService: ObservableObject {
    
    @Published var localUserICloudID: String = ""
    @Published var localUserName: String = ""
    @Published var localUser: SiggyUserModel?
    @Published var isRegistered: Bool = false
    @Published var users: [SiggyUserModel] = []
    var cancellables = Set<AnyCancellable>()

    
    init(completion: @escaping () -> Void) {
        CKUtilityService.getiCloudStatus()
        CKUtilityService.requestApplicationPermission()

        CKUtilityService.discoverUserIdentity()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { id in
                
                self.localUserICloudID = id
            }
            .store(in: &cancellables)
        
        CKUtilityService.discoverUserName()
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { name in
                self.localUserName = name
                self.fetchUser() {}
                completion()
            }
            .store(in: &cancellables)
        
        
    }
    
    func addUser() {
        guard let newUser = SiggyUserModel(username: localUserName, turns: 0, id: localUserICloudID) else { return }
        CKUtilityService.add(item: newUser) { result in
            
        }
    }
    
    func fetchUser(completion: @escaping () -> Void){
        let predicate = NSPredicate(format: "id == %@", localUserICloudID)
        let recordType = "SiggyTurn"
        CKUtilityService.fetch(predicate: predicate, recordType: recordType)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { (returnedUsers: [SiggyUserModel]) in
                if(returnedUsers.count > 0){
                    self.isRegistered = true
                    self.localUser = returnedUsers.first
                    guard let user = returnedUsers.first else {return}
                    UserDefaults.standard.user = user
                } else {
                    if(UserDefaults.standard.userID != self.localUserICloudID || !self.isRegistered){
                        UserDefaults.standard.userID = ""
                        self.addUser()
                         
                    }
                }
                completion()
                return
            }
            .store(in: &cancellables)
        
        
    }
    
    func fetchAllUsers() {
        let predicate = NSPredicate(value: true)
        let recordType = "SiggyTurn"
        
        CKUtilityService.fetch(predicate: predicate, recordType: recordType)
            .receive(on: DispatchQueue.main)
            .sink { _ in
                
            } receiveValue: { [weak self] (returnedUsers: [SiggyUserModel]) in
                self?.users = []
                returnedUsers.forEach { user in
                    self?.users.append(user)
                }
                self?.users.sort { $0.turns > $1.turns }
            }
            .store(in: &cancellables)
    }
    
    func update(newTurns: Int) {
        guard let newUser = self.localUser?.update(newTurns: newTurns) else { return }
        CKUtilityService.update(item: newUser) { result in
        }
    }
    
    func getSiggyUserRecordFromICloudID(userID: String) -> SiggyUserModel?{
        return users.first(where: { $0.id == userID })
    }
}
