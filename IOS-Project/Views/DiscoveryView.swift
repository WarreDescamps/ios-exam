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
    @StateObject var mangadex = MangadexSdk()
    @State var userId: String
    @State private var query: String = ""
    
    @State private var selectionState: ViewState = .viewing
    @State private var selectedManga = [Manga]()
    
    init(userId: String) {
        self.userId = userId
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),
                          alignment: .center, spacing: 10.0) {
                    ForEach(self.mangadex.manga, id: \.id) { manga in
                        SelectableMangaGridItem(manga: manga, selectionState: $selectionState, selectedManga: $selectedManga)
                    }
                }
                .padding(.horizontal)
                .if(selectionState == .selecting) { view in
                    view
                        .toolbar {
                            ToolbarItem() {
                                Button(action: addManga) {
                                    Label("Cancel", systemImage: "x.circle.fill")
                                }
                                .tint(.red)
                                Spacer()
                                Button(action: addManga) {
                                    Label("Add", systemImage: "plus.circle.fill")
                                }
                            }
                        }
                }
            }
            //.refreshable(action: initData)
        }
        .searchable(text: $query)
        .onSubmit(of: .search, initData)
    }
    
    private func initData() {
        var realQuery: String? = query
        if query == "" {
            realQuery = nil
        }
        self.mangadex.getManga(query: realQuery)
    }
    
    private func loadMore() {
        self.mangadex.loadNextPage()
    }
    
    private func addManga() {
        
    }
}

extension View {
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView(userId: "w5sWxDHUmHddIQNnAQy5JcGjNRP2")
            .environmentObject(MangadexSdk())
    }
}
