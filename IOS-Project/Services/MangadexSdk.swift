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
    
    private func appendWithCoverUrl(manga: Manga){
        var manga = manga
        Api.Sdk.shared
            .get(.cover(id: manga.id)) { (result: Result<Api.Types.Response.MangadexCover, Api.Types.Error>) in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let success):
                        var fileName: String = ""
                        fileName = success.data.first?.attributes.fileName ?? ""
                        if fileName == "" {
                            manga.coverUrl = fileName
                        } else {
                            manga.coverUrl += fileName
                        }
                        self.manga.append(manga)
                    case .failure(let failure):
                        print(failure.localizedDescription)
                    }
                }
            }
    }
    
    private func appendManga(_ success: Api.Types.Response.MangadexManga) {
        for result in success.data {
            if self.manga.allSatisfy({ $0.id != result.id }) {
                let title = result.attributes.title["en"]
                    ?? result.attributes.title["ja"]
                    ?? result.attributes.title["ko"]
                    ?? result.attributes.title["ru"]
                    ?? result.attributes.title["pt"]
                    ?? ""
                let description = result.attributes.description["en"]
                    ?? result.attributes.description["ja"]
                    ?? result.attributes.description["ko"]
                    ?? result.attributes.description["ru"]
                    ?? result.attributes.description["pt"]
                    ?? ""
                var genres = [String]()
                for tag in result.attributes.tags {
                    if tag.group == Api.Types.Response.Group.genre.asString {
                        if let name = tag.attributes.name["en"] {
                            genres.append(name)
                        }
                    }
                }
                self.appendWithCoverUrl(manga: Manga(id: result.id,
                                                     title: title,
                                                     description: description,
                                                     genres: genres,
                                                     coverUrl: "https://mangadex.org/covers/\(result.id)/"))
            }
        }
    }
    
    private func fetchManga(query: String?){
        Api.Sdk.shared
            .get(.mangaSearch(query: query, page: page)) { (result: Result<Api.Types.Response.MangadexManga, Api.Types.Error>) in
                switch result {
                case .success(let success):
                    self.appendManga(success)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
    }
    
    private func fetchManga(mangaIds: [String]) {
        Api.Sdk.shared
            .get(.mangaById(mangaIds: mangaIds)) { (result: Result<Api.Types.Response.MangadexManga, Api.Types.Error>) in
                switch result {
                case .success(let success):
                    self.appendManga(success)
                case .failure(let failure):
                    print(failure.localizedDescription)
                }
            }
    }
    
    func getManga(query: String?) {
        page = 0
        lastQuery = query
        manga.removeAll()
        fetchManga(query: query)
    }
    
    func getMangaById(mangaIds: [String]) {
        manga.removeAll()
        var mangaIds = mangaIds
        while mangaIds.count > 0 {
            fetchManga(mangaIds: mangaIds)
            if mangaIds.count > 100 {
                mangaIds = Array(mangaIds[100...])
            }
            else {
                mangaIds = []
            }
        }
    }
    
    func loadNextPage() {
        page += 1
        fetchManga(query: lastQuery)
    }
}
