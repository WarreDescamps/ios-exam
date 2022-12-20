//
//  SingletonManager.swift
//  IOS-Project
//
//  Created by docent on 09/12/2022.
//

import Foundation

struct SingletonManager {
    private static var instances = [String: MangadexSdk]()
    private static var userInstance: String? = nil
    
    static func instance(key: String) -> MangadexSdk {
        if let value = instances[key] {
            return value
        }
        let value = MangadexSdk()
        instances[key] = value
        return value
    }
    
    static func userInstance(userId: String? = nil) -> String? {
        if let userId = userId {
            self.userInstance = userId
            HistoryManager.shared.fetchFullHistory()
        }
        return self.userInstance
    }
}
