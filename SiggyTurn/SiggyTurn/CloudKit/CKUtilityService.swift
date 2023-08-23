import Foundation
import CloudKit
import Combine

protocol CloudKitProtocol {
    init?(record: CKRecord)
    var record: CKRecord { get }
}

class CKUtilityService {

    enum CloudKitError: String, LocalizedError {
        case iCloudAccountNotFound
        case iCloudAccountNotDetermined
        case iCloudAccountRestricted
        case iCloudAccountUnknown
        case iCloudApplicationPermissionNotGranted
        case iCloudCouldNotFetchUserRecordID
        case iCloudCouldNotDiscoverUser
    }
}


//MARK: USER FUNCTIONS
extension CKUtilityService {
    
    static private func getiCloudStatus(completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().accountStatus { returnedStatus, returnedError in
            switch returnedStatus {
            case .available:
                completion(.success(true))
            case .noAccount:
                completion(.failure(CloudKitError.iCloudAccountNotFound))
            case .couldNotDetermine:
                completion(.failure(CloudKitError.iCloudAccountNotDetermined))
            case .restricted:
                completion(.failure(CloudKitError.iCloudAccountRestricted))
            default:
                completion(.failure(CloudKitError.iCloudAccountUnknown))
            }
        }
    }
    
    static func getiCloudStatus() -> Future<Bool, Error> {
        Future { promise in
            CKUtilityService.getiCloudStatus { result in
                promise(result)
            }
        }
    }

    
    static private func requestApplicationPermission(completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().requestApplicationPermission([.userDiscoverability]) { returnedStatus, returnedError in
            if returnedStatus == .granted {
                completion(.success(true))
            } else {
                completion(.failure(CloudKitError.iCloudApplicationPermissionNotGranted))
            }
        }
    }
    
    static func requestApplicationPermission() -> Future<Bool, Error> {
        Future { promise in
            CKUtilityService.requestApplicationPermission { result in
                promise(result)
            }
        }
    }
    
    static func fetchUserRecordID(completion: @escaping (Result<CKRecord.ID, Error>) -> ()) {
        CKContainer.default().fetchUserRecordID { returnedID, returnedError in
            if let id = returnedID {
                completion(.success(id))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotFetchUserRecordID))
            }
        }
    }
            
    
    static private func discoverUserIdentity(completion: @escaping (Result<String, Error>) -> ()) {
        fetchUserRecordID { fetchCompletion in
            switch fetchCompletion {
            case .success(let recordID):
                completion(.success(recordID.recordName))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    
    static func discoverUserIdentity() -> Future<String, Error> {
        Future { promise in
            CKUtilityService.discoverUserIdentity { result in
                promise(result)
            }
        }
    }
    
    static func discoverUserIdentit(completion: @escaping ((Result<String, Error>) -> Void))  {
            CKUtilityService.discoverUserIdentity { result in
                completion(result)
            }
    }
    
    static private func discoverUserName(completion: @escaping (Result<String, Error>) -> ()) {
        fetchUserRecordID { fetchCompletion in
            switch fetchCompletion {
            case .success(let recordID):
                CKUtilityService.discoverUserName(id: recordID, completion: completion)
            case .failure(let error):
                completion(.failure(error))
            }
            
        }
    }
    
    
    static private func discoverUserName(id: CKRecord.ID, completion: @escaping (Result<String, Error>) -> ()) {
        CKContainer.default().discoverUserIdentity(withUserRecordID: id) {  returnedIdentity, returnedError in
            if let name = returnedIdentity?.nameComponents?.givenName {
                completion(.success(name))
            } else {
                completion(.failure(CloudKitError.iCloudCouldNotDiscoverUser))
            }
        }
    }
    
    static func discoverUserName() -> Future<String, Error> {
         Future { promise in
             CKUtilityService.discoverUserName { result in
                 promise(result)
             }
         }
    }
    
}

//MARK: CRUD FUNCTIONS

extension CKUtilityService {
    
    static func fetch<T:CloudKitProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil) -> Future<[T], Error> {
        Future { promise in
            CKUtilityService.fetch(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit) { (items: [T]) in
                promise(.success(items))
            }
        }
    }
    
    static private func fetch<T:CloudKitProtocol>(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil,
        completion: @escaping (_ items: [T]) -> ())
    {
        // Create operation
        let operation = createOperation(predicate: predicate, recordType: recordType, sortDescriptors: sortDescriptors, resultsLimit: resultsLimit)
        
        // Get items in query
        var returnedItems: [T] = []
        addRecordedMatchedBlock(operation: operation) { item in
            returnedItems.append(item)
        }
        
        //Query completion
        addQueryResultBlock(operation: operation) { finished in
            completion(returnedItems)
        }

        // Execute the operation
        add(operation: operation)
    }
    
    static private func createOperation(
        predicate: NSPredicate,
        recordType: CKRecord.RecordType,
        sortDescriptors: [NSSortDescriptor]? = nil,
        resultsLimit: Int? = nil) -> CKQueryOperation {
            let query = CKQuery(recordType: recordType, predicate: predicate)
            query.sortDescriptors = sortDescriptors
            let queryOperation = CKQueryOperation(query: query)
            if let limit = resultsLimit {
                queryOperation.resultsLimit = limit
            }
            return queryOperation
        }
    
    static private func addRecordedMatchedBlock<T:CloudKitProtocol>(operation: CKQueryOperation, completion: @escaping (_ item: T) -> ()) {
        if #available(iOS 15.0, *) {
            operation.recordMatchedBlock = { (returnedRecordID, returnedResult) in
                switch returnedResult {
                case .success(let record):
                    guard let item = T(record: record) else { return }
                    completion(item)
                case .failure:
                    break
                }
            }
        } else {
            operation.recordFetchedBlock = { (returnedRecord) in
                guard let item = T(record: returnedRecord) else { return }
                completion(item)
            }
        }
    }
    
    static private func addQueryResultBlock(operation: CKQueryOperation, completion: @escaping (_ finished: Bool) -> ()) {
        if #available(iOS 15.0, *) {
            operation.queryResultBlock = { returnedResult in
                completion(true)
            }
        }else {
            operation.queryCompletionBlock = { (returnedCursor, returnedError) in
                completion(true)
            }
        }
    }
    
    static private func add(operation: CKDatabaseOperation) {
        CKContainer.default().publicCloudDatabase.add(operation)
    }
    
    static func add<T:CloudKitProtocol>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
        
        // Get record
        let record = item.record
        
        // Save to CloudKit
        save(record: record, completion: completion)
    }
    
    static func update<T:CloudKitProtocol>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
        add(item: item, completion: completion)
    }
    
    static private func save(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.save(record) { returnedRecord, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }

    static func delete<T:CloudKitProtocol>(item: T) -> Future<Bool, Error> {
        Future { promise in
            CKUtilityService.delete(item: item, completion: promise)
        }
    }
    
    static private func delete<T:CloudKitProtocol>(item: T, completion: @escaping (Result<Bool, Error>) -> ()) {
        CKUtilityService.delete(record: item.record, completion: completion)
    }
    
    static private func delete(record: CKRecord, completion: @escaping (Result<Bool, Error>) -> ()) {
        CKContainer.default().publicCloudDatabase.delete(withRecordID: record.recordID) { returnedRecordID, returnedError in
            if let error = returnedError {
                completion(.failure(error))
            } else {
                completion(.success(true))
            }
        }
    }
}
