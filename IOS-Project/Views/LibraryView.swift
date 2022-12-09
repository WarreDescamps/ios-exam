//
//  LibraryView.swift
//  IOS-Project
//
//  Created by docent on 25/11/2022.
//

import SwiftUI

struct LibraryView: View {
    @StateObject var mangadex = SingletonManager.instance(key: "library")
    private let userId: String
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),
                          alignment: .center, spacing: 10.0) {
                    ForEach(self.mangadex.manga, id: \.id) { manga in
                        MangaGridItem(manga: manga)
                    }
                }
                .padding(.horizontal)
            }
            .navigationTitle("Library")
        }
        .onAppear(perform: initData)
    }
    
    func initData() {
        MangaManager.shared.getManga(userId: userId) { mangaIds in
            SingletonManager.instance(key: "library").getMangaById(mangaIds: mangaIds)
        }
    }
}

struct LibraryView_Previews: PreviewProvider {
    static var previews: some View {
        LibraryView(userId: DebugConstants.userId)
    }
}
