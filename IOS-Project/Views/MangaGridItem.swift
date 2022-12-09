//
//  MangaGridItem.swift
//  IOS-Project
//
//  Created by Warre Descamps on 07/12/2022.
//

import SwiftUI

struct MangaGridItem: View {
    var manga: Manga
    
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
    }
}

struct SelectableMangaGridItem: View {
    var manga: Manga
    
    @Binding var selectionState: ViewState
    @Binding var selectedManga: [Manga]
    
    var body: some View {
        MangaGridItem(manga: manga)
            .if(selectionState == .viewing) { view in
                view
                    .onTapGesture {}
                    .onLongPressGesture() {
                        DispatchQueue.main.async {
                            selectedManga.removeAll()
                            selectedManga.append(manga)
                            selectionState = .selecting
                        }
                    }
            }
            .if(selectionState == .selecting) { view in
                view
                    .onTapGesture {
                        DispatchQueue.main.async {
                            if selectedManga.contains(where: { $0.id == manga.id }) {
                                selectedManga.removeAll(where: { $0.id == manga.id })
                            }
                            else {
                                selectedManga.append(manga)
                            }
                        }
                    }
            }
            .if(selectedManga.contains(where: { $0.id == manga.id })) { view in
                view
                    .scaleEffect(0.92)
                    .shadow(color: .orange, radius: 10)
//                                    .background(
//                                        Color.blue
//                                            .clipShape(RoundedRectangle(cornerRadius: 10))
//                                    )
            }
    }
}

struct MangaGridItem_Previews: PreviewProvider {
    static var previews: some View {
        MangaGridItem(manga: Manga(id: "1", title: "World Trigger", description: "A portal opens blah di blah di blah", coverUrl: "https://mangadex.org/covers/7ae7067a-7e68-4bd2-a064-5e3e3c059078/6742f549-20ec-48fa-ba7a-e9c54cac5ebb.jpg.512.jpg"))
    }
}
