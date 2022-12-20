//
//  LibraryView.swift
//  IOS-Project
//
//  Created by docent on 25/11/2022.
//

import SwiftUI

struct LibraryView: View {
    @StateObject var mangadex = SingletonManager.instance(key: "library")
    @State private var isMangaDetailShown = false
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),
                          alignment: .center, spacing: 10.0) {
                    ForEach(self.mangadex.manga) { manga in
                        MangaGridItem(manga: manga, showDetail: $isMangaDetailShown, parentTitle: "Library")
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Library")
        }
        .onAppear(perform: initData)
    }
    
    func initData() {
        MangaManager.shared.getManga() { mangaIds in
            SingletonManager.instance(key: "library").getMangaById(mangaIds: mangaIds)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView_PreviewContainer()
    }
}

struct LibraryView_PreviewContainer: View {
    init() {
        _ = SingletonManager.userInstance(userId: DebugConstants.userId)
    }
    
    var body: some View {
        LibraryView()
    }
}
