//
//  LibraryView.swift
//  IOS-Project
//
//  Created by docent on 25/11/2022.
//

import SwiftUI

struct LibraryView: View {
    @ObservedObject private var mangadex = MangadexSdk()
    private let mangaManager: MangaManager
    private let userId: String
    
    init(userId: String, mangaManager: MangaManager) {
        self.userId = userId
        self.mangaManager = mangaManager
        initData()
    }
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),
                      alignment: .center, spacing: 10.0) {
                ForEach(mangadex.manga, id: \.id) { manga in
                    MangaGridItem(manga: manga)
                }
            }
        }
    }
    
    private func initData() {
        mangaManager.getManga(userId: userId) { mangaIds in
            mangadex.getMangaById(mangaIds: mangaIds)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(userId: "w5sWxDHUmHddIQNnAQy5JcGjNRP2", mangaManager: MangaManager())
    }
}
