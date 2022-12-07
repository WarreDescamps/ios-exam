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
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center, spacing: 5) {
                ForEach(mangaManager.manga, id: \.id) { manga in
                    VStack {
                        AsyncImage(url: URL(string: manga.coverUrl),
                                   content: { image in image.resizable() },
                                   placeholder: { Color.gray })
                            .aspectRatio(contentMode: .fill)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
