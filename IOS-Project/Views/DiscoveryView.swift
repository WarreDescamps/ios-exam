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
    @State var query: String? = nil
    
    var body: some View {
        ScrollView {
            
            
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], alignment: .center, spacing: 5) {
                ForEach(mangadex.manga, id: \.id) { manga in
                    ZStack {
                        AsyncImage(url: URL(string: manga.coverUrl),
                                   content: { image in image.resizable() },
                                   placeholder: { Color.gray })
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 90)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                        Text(manga.title)
                    }
                }
            }
        }
        .onAppear { initData() }
    }
    
    private func initData() {
        mangadex.getManga(query: query)
    }
}

struct DiscoveryView_Previews: PreviewProvider {
    static var previews: some View {
        DiscoveryView(userId: "w5sWxDHUmHddIQNnAQy5JcGjNRP2")
            .environmentObject(MangadexSdk())
    }
}
