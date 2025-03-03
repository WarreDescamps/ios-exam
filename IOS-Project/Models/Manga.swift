//
//  Manga.swift
//  IOS-Project
//
//  Created by Warre Descamps on 02/12/2022.
//

import Foundation

struct Manga: Identifiable, Hashable {
    var id: String
    var title: String
    var authors: [String]
    var description: String
    var genres: [String]
    var coverUrl: String
}
