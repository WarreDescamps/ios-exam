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
        ScrollView {
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center, spacing: 5) {
                ForEach(mangaManager.manga, id: \.id) { manga in
                    HStack {
                        Image(manga.coverUrl)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                        Text(manga.title)
                    }
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
