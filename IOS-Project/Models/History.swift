//
//  History.swift
//  IOS-Project
//
//  Created by Warre Descamps on 20/12/2022.
//

import Foundation

struct History: Identifiable, Hashable {
    var mangaId: String
    var lastRead: Date?
    var chapters: [String]
    
    var id: String {
        mangaId
    }
}
