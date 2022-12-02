//
//  LibraryView.swift
//  IOS-Project
//
//  Created by docent on 25/11/2022.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var mangaManager: MangaManager
    let userId: String
    
    var body: some View {
        List(mangaManager.manga) { manga in
            AsyncImage(url: URL(string: manga.coverUrl))
            Text(manga.title)
        }
        .onAppear { initData() }
    }
    
    private func initData() {
        mangaManager.getManga(userId: userId)
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(userId: "w5sWxDHUmHddIQNnAQy5JcGjNRP2")
            .environmentObject(MangaManager())
    }
}
