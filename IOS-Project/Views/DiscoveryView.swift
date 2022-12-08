//
//  DiscoveryView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 05/12/2022.
//

import SwiftUI

enum ViewState {
    case viewing
    case selecting
}

struct DiscoveryView: View {
    @ObservedObject var mangadex = MangadexSdk()
    @State var userId: String
    @State private var query: String = ""
    @State private var selectionState: ViewState = .viewing
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),
                          alignment: .center, spacing: 10.0) {
                    ForEach(mangadex.manga, id: \.id) { manga in
                        MangaGridItem(manga: manga)
                    }
                }
                .padding(.horizontal)
            }
        }
        .searchable(text: $query)
        .onSubmit(of: .search, initData)
    }
    
    private func initData() {
        var realQuery: String? = query
        if query == "" {
            realQuery = nil
        }
        mangadex.getManga(query: realQuery)
        print(mangadex.manga)
    }
    
    private func loadMore() {
        mangadex.loadNextPage()
    }
}

struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView(userId: "w5sWxDHUmHddIQNnAQy5JcGjNRP2")
            .environmentObject(MangadexSdk())
    }
}
