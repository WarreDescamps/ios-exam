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
    @StateObject var mangadex = SingletonManager.instance(key: "discovery")
    @State private var query: String = ""
    
    @State private var selectionState: ViewState = .viewing
    @State private var selectedManga = [Manga]()
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2),
                          alignment: .center, spacing: 10.0) {
                    ForEach(self.mangadex.manga, id: \.id) { manga in
                        SelectableMangaGridItem(manga: manga,
                                                parentTitle: "Discovery",
                                                selectionState: $selectionState,
                                                selectedManga: $selectedManga)
                    }
                    Color.clear
                        .onAppear(perform: loadMore)
                }
                .padding(.horizontal)
            }
            .navigationTitle("Discovery")
            .if(selectionState == .selecting) { view in
                view
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) {
                            Button(action: cancelSelection) {
                                Label("Cancel", systemImage: "x.circle.fill")
                            }
                            .labelStyle(.titleAndIcon)
                            .tint(.red)
                        }
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button(action: addManga) {
                                Label("Add", systemImage: "plus.circle.fill")
                            }
                            .labelStyle(.titleAndIcon)
                        }
                    }
            }
        }
        .onChange(of: selectedManga.count) { newVal in
            if newVal == 0 {
                cancelSelection()
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
        SingletonManager.instance(key: "discovery").getManga(query: realQuery)
    }
    
    private func loadMore() {
        SingletonManager.instance(key: "discovery").loadNextPage()
    }
    
    private func addManga() {
        for manga in selectedManga {
            MangaManager.shared.addManga(manga: manga)
        }
    }
    
    private func cancelSelection() {
        selectionState = .viewing
        selectedManga = []
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
        DiscoveryView()
            .environmentObject(MangadexSdk())
    }
}
