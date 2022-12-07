//
//  Mangadex.swift
//  IOS-Project
//
//  Created by Warre Descamps on 05/12/2022.
//

import SwiftUI

class MangadexSdk: ObservableObject {
    @Published var manga = [Manga]()
    @State private var page = 0
    @State private var lastQuery: String? = nil
    
    init() {
        getManga(query: nil)
    }
    
    private func appendWithCoverUrl(manga: Manga){
        var manga = manga
        Api.Sdk.shared
            .get(.cover(id: manga.id)) { (result: Result<Api.Types.Response.CoverLookup, Api.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        var fileName: String = ""
                        fileName = success.data.first(where: { cover in cover.attributes.locale == "en" })?.attributes.fileName ?? ""
                        if fileName == "" {
                            fileName = success.data.first?.attributes.fileName ?? ""
                        }
                        manga.coverUrl += fileName
                        self.manga.append(manga)
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            }
    }
    
    private func fetchManga(query: String?){
        Api.Sdk.shared
            .get(.manga(query: query, page: page)) { (result: Result<Api.Types.Response.MangaSearch, Api.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        for result in success.data {
                            self.appendWithCoverUrl(manga: Manga(id: result.id,
                                                                 title: result.attributes.title.en,
                                                                 description: result.attributes.description.en,
                                                                 coverUrl: "https://uploads.mangadex.org/covers/\(result.id)/"))
                    }
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            }
    }
    
    func getManga(query: String?) {
        page = 0
        lastQuery = query
        manga.removeAll()
        fetchManga(query: query)
    }
    
    func loadNextPage() {
        page += 1
        fetchManga(query: lastQuery)
    }
}
