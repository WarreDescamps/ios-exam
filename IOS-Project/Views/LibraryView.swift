//
//  LibraryView.swift
//  IOS-Project
//
//  Created by docent on 25/11/2022.
//

import SwiftUI

struct LibraryView: View {
    @EnvironmentObject var mangaManager: MangaManager
    @State var userId: String
    
    var body: some View {
        ScrollView {
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), alignment: .center, spacing: 10.0) {
                ForEach(mangaManager.manga, id: \.id) { manga in
                    MangaGridItem(manga: manga)
                }
            }
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
