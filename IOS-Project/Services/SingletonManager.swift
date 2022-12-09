//
//  SingletonManager.swift
//  IOS-Project
//
//  Created by docent on 09/12/2022.
//

import Foundation

struct SingletonManager {
    private static var instances = [String: MangadexSdk]()
    
    static func instance(key: String) -> MangadexSdk {
        if let value = instances[key] {
            return value
        }
        let value = MangadexSdk()
        instances[key] = value
        return value
    }
}
