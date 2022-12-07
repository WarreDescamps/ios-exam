//
//  DiscoveryView.swift
//  IOS-Project
//
//  Created by Warre Descamps on 05/12/2022.
//

import SwiftUI

struct DiscoveryView: View {
    @EnvironmentObject var mangadex: MangadexSdk
    @State var userId: String
    @State private var query: String = ""
    
    var body: some View {
        NavigationStack {
            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center, spacing: 5) {
                    ForEach(mangadex.manga, id: \.id) { manga in
                        VStack {
                            AsyncImage(url: URL(string: manga.coverUrl),
                                       content: { image in image.resizable() },
                                       placeholder: { Color.gray })
                                .aspectRatio(contentMode: .fill)
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                            Text(manga.title)
                                .multilineTextAlignment(.center)
                                .lineLimit(1)
                        }
                    }
                }
                .padding(.horizontal)
            }
        }
        .searchable(text: $query)
        .onAppear(perform: initData)
        .onSubmit(of: .search, initData)
        
    }
    
    private func initData() {
        var realQuery: String? = query
        if query == "" {
            realQuery = nil
        }
        mangadex.getManga(query: realQuery)    }
}

struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView(userId: "w5sWxDHUmHddIQNnAQy5JcGjNRP2")
            .environmentObject(MangadexSdk())
    }
}
