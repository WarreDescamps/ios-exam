//
//  MangaGridItem.swift
//  IOS-Project
//
//  Created by Warre Descamps on 07/12/2022.
//

import SwiftUI

struct MangaGridItem: View {
    @State var manga: Manga
    
    var body: some View {
        AsyncImage(url: URL(string: manga.coverUrl),
                   content: { image in image.resizable() },
                   placeholder: {
                        ZStack {
                            Color.gray
                            ProgressView()
                                .progressViewStyle(.circular)
                        }
                    })
        //.aspectRatio(contentMode: .fit)
        .aspectRatio(0.66, contentMode: .fit)
        .overlay(alignment: .bottom) {
            LinearGradient(gradient: Gradient(colors: [.black, .clear]), startPoint: .bottom, endPoint: .top)
                .frame(height: 90.0)
        }
        .overlay(alignment: .bottomLeading) {
            Text(manga.title)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
                .lineLimit(2)
                .padding([.leading, .bottom], 5.0)
        }
        .clipShape(RoundedRectangle(cornerRadius: 10))
        #if DEBUG
        .overlay() {
            GeometryReader { proxy in
                Text("\(proxy.size.width)x\(proxy.size.height)")
            }
        }
        #endif
    }
}

struct MangaGridItem_Previews: PreviewProvider {
    static var previews: some View {
        MangaGridItem(manga: Manga(id: "1", title: "World Trigger", description: "A portal opens blah di blah di blah", coverUrl: "https://mangadex.org/covers/7ae7067a-7e68-4bd2-a064-5e3e3c059078/6742f549-20ec-48fa-ba7a-e9c54cac5ebb.jpg.512.jpg"))
    }
}
