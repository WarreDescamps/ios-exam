//
//  Chapter.swift
//  IOS-Project
//
//  Created by Warre Descamps on 11/12/2022.
//

import Foundation

struct Chapter: Identifiable, Hashable {
    var id: String
    var number: String
    var title: String?
    var updatedAt: Date
}
